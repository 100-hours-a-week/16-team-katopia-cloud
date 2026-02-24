// 마이그레이션 설계를 검증하기 위한 부하테스트
// 투표 생성 API를 지속적으로 호출해 동시성 안정성을 검증한다.

import { sleep } from 'k6';
import { Counter } from 'k6/metrics';
import { THRESHOLDS, LOAD_CONFIG } from '../configs/v1.js';
import * as api from '../utils/requests.js';
import * as checks from '../utils/checks.js';

const FIXED_VUS = 10;
const TEST_DURATION = __ENV.TEST_DURATION || LOAD_CONFIG.STABLE_DURATION;
const SLEEP_SECONDS = Number(__ENV.SLEEP_SECONDS || 3);
const BUCKET_SECONDS = 10;
const VOTE_IMAGE_OBJECT_KEY = __ENV.VOTE_IMAGE_OBJECT_KEY || 'load-test/default-image.jpg';
const STATUS_CODES_TO_TRACK = [0, 200, 201, 400, 401, 403, 404, 409, 422, 429, 500, 502, 503, 504];
const MAX_FAILURE_LOGS_PER_VU = 2;

const bucketRequests = new Counter('bucket_requests');
const bucketErrors = new Counter('bucket_errors');
const statusCount = new Counter('status_count');
let failureLogsPrinted = 0;

function parseDurationToSeconds(duration) {
  const regex = /(\d+)(ms|s|m|h)/g;
  const text = String(duration);
  let totalSeconds = 0;
  let match;

  while ((match = regex.exec(text)) !== null) {
    const value = Number(match[1]);
    const unit = match[2];

    if (unit === 'h') totalSeconds += value * 3600;
    if (unit === 'm') totalSeconds += value * 60;
    if (unit === 's') totalSeconds += value;
    if (unit === 'ms') totalSeconds += value / 1000;
  }

  return Math.max(1, Math.ceil(totalSeconds));
}

function buildBucketThresholds() {
  const totalSeconds = parseDurationToSeconds(TEST_DURATION);
  const totalBuckets = Math.ceil(totalSeconds / BUCKET_SECONDS);
  const bucketThresholds = {};

  for (let bucket = 0; bucket < totalBuckets; bucket++) {
    bucketThresholds[`bucket_requests{time_bucket:${bucket}}`] = [];
    bucketThresholds[`bucket_errors{time_bucket:${bucket}}`] = [];
  }

  return bucketThresholds;
}

function buildStatusThresholds() {
  const statusThresholds = {};
  for (const code of STATUS_CODES_TO_TRACK) {
    statusThresholds[`status_count{status_code:${code}}`] = [];
  }
  return statusThresholds;
}

export function setup() {
  return { startTime: Date.now() };
}

export const options = {
  scenarios: {
    migration_vote_constant: {
      executor: 'constant-vus',
      vus: FIXED_VUS,
      duration: TEST_DURATION,
      gracefulStop: '0s',
    },
  },
  thresholds: Object.assign({}, THRESHOLDS, buildBucketThresholds(), buildStatusThresholds()),
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(95)', 'p(99)'],
};

function getTimeBucket(startTime) {
  const elapsedSec = Math.floor((Date.now() - startTime) / 1000);
  return Math.floor(elapsedSec / BUCKET_SECONDS);
}

function recordBucketMetrics(response, bucket) {
  const tags = { time_bucket: String(bucket) };
  bucketRequests.add(1, tags);

  if (response.status >= 400 || response.status === 0) {
    bucketErrors.add(1, tags);
  }
}

function recordStatusMetrics(response) {
  statusCount.add(1, { status_code: String(response.status) });
}

function logFailureSample(response) {
  if (response.status > 0 && response.status < 400) return;
  if (failureLogsPrinted >= MAX_FAILURE_LOGS_PER_VU) return;

  const body = String(response.body || '').replace(/\s+/g, ' ').slice(0, 240);
  console.error(`[FAIL_SAMPLE] status=${response.status} body="${body}"`);
  failureLogsPrinted += 1;
}

function generateVoteTitle() {
  const iteration = __ITER + 1;
  return `vote-${__VU}-${iteration}`;
}

export default function (setupData) {
  const bucket = getTimeBucket(setupData.startTime);
  const title = generateVoteTitle();
  const imageObjectKeys = [VOTE_IMAGE_OBJECT_KEY];

  const res = api.createVote(title, imageObjectKeys);
  recordBucketMetrics(res, bucket);
  recordStatusMetrics(res);
  logFailureSample(res);
  checks.checkVoteCreated(res, 'create_vote');

  sleep(SLEEP_SECONDS);
}

export function handleSummary(data) {
  const bucketStats = {};

  Object.keys(data.metrics).forEach((metricName) => {
    const match = metricName.match(/time_bucket:(\d+)/);
    const metric = data.metrics[metricName];
    if (match) {
      const bucket = parseInt(match[1], 10);
      if (!bucketStats[bucket]) {
        bucketStats[bucket] = { requests: 0, errors: 0 };
      }

      if (metricName.includes('bucket_requests')) {
        bucketStats[bucket].requests = metric.values.count || 0;
      } else if (metricName.includes('bucket_errors')) {
        bucketStats[bucket].errors = metric.values.count || 0;
      }
    }
  });

  const buckets = Object.keys(bucketStats)
    .map((n) => parseInt(n, 10))
    .sort((a, b) => a - b);

  let totalRequests = 0;
  let totalErrors = 0;

  let table = `\n\n      시간 구간별 실패율 (${BUCKET_SECONDS}s bucket)\n\n`;
  table += '='.repeat(78) + '\n';
  table += '구간(start~end sec)     | 요청수       | 실패수       | 실패율\n';
  table += '-'.repeat(78) + '\n';

  buckets.forEach((bucket) => {
    const stats = bucketStats[bucket];
    const start = bucket * BUCKET_SECONDS;
    const end = (bucket + 1) * BUCKET_SECONDS;
    const errorRate =
      stats.requests > 0 ? ((stats.errors / stats.requests) * 100).toFixed(2) : '0.00';

    totalRequests += stats.requests;
    totalErrors += stats.errors;

    table += `${String(`${start}~${end}`).padEnd(24)} | ${String(stats.requests).padStart(11)} | ${String(
      stats.errors
    ).padStart(11)} | ${(errorRate + '%').padStart(7)}\n`;
  });

  const totalErrorRate =
    totalRequests > 0 ? ((totalErrors / totalRequests) * 100).toFixed(2) : '0.00';

  table += '-'.repeat(78) + '\n';
  table += `${'TOTAL'.padEnd(24)} | ${String(totalRequests).padStart(11)} | ${String(
    totalErrors
  ).padStart(11)} | ${(totalErrorRate + '%').padStart(7)}\n`;
  table += '='.repeat(78) + '\n';

  return {
    stdout: table,
  };
}
