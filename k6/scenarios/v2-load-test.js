// scenarios/load-test.js
import { sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';
import { THRESHOLDS, LOAD_CONFIG, SCROLL_CONFIG } from '../configs/v1.js';
import * as api from '../utils/requests.js';
import * as checks from '../utils/checks.js';
import * as data from '../utils/data.js';

// VU 단계별 커스텀 메트릭
const vuStageTrend = new Trend('vu_stage_duration');
const vuStageErrors = new Counter('vu_stage_errors');
const vuStageRequests = new Counter('vu_stage_requests');

const extendedThresholds = Object.assign({}, THRESHOLDS);
for (let vu = LOAD_CONFIG.INITIAL_VU; vu <= LOAD_CONFIG.MAX_VU; vu += LOAD_CONFIG.VU_INCREMENT) {
  extendedThresholds[`vu_stage_duration{vu_stage:${vu}}`] = [];
  extendedThresholds[`vu_stage_requests{vu_stage:${vu}}`] = [];
  extendedThresholds[`vu_stage_errors{vu_stage:${vu}}`] = [];
}

export function setup() {
  return { startTime: Date.now() };
}

// 시간 기반으로 현재 VU 단계 계산
function getCurrentVUStage(startTime) {
  const elapsedMs = Date.now() - startTime;
  const elapsedSec = elapsedMs / 1000;

  const rampDurationSec = parseInt(LOAD_CONFIG.RAMP_DURATION);
  const stageIndex = Math.floor(elapsedSec / rampDurationSec);
  const vuStage = LOAD_CONFIG.INITIAL_VU + (stageIndex * LOAD_CONFIG.VU_INCREMENT);

  return Math.min(vuStage, LOAD_CONFIG.MAX_VU);
}

// 부하 모델링 설정
function generateStages() {
  const stages = [];
  for (let vu = LOAD_CONFIG.INITIAL_VU; vu <= LOAD_CONFIG.MAX_VU; vu += LOAD_CONFIG.VU_INCREMENT) {
    stages.push({ duration: LOAD_CONFIG.RAMP_DURATION, target: vu });
  }
  stages.push({ duration: LOAD_CONFIG.STABLE_DURATION, target: LOAD_CONFIG.MAX_VU });
  return stages;
}

// VU 단계 목록 생성
function getVUStages() {
  const stages = [];
  for (let vu = LOAD_CONFIG.INITIAL_VU; vu <= LOAD_CONFIG.MAX_VU; vu += LOAD_CONFIG.VU_INCREMENT) {
    stages.push(vu);
  }
  return stages;
}

export const options = {
  stages: generateStages(),
  thresholds: extendedThresholds,
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(95)', 'p(99)'],
};

// 메트릭 기록 함수 (startTime 추가)
function recordMetrics(response, startTime) {
  const vuStage = getCurrentVUStage(startTime);
  const tags = { vu_stage: String(vuStage) };

  vuStageTrend.add(response.timings.duration, tags);
  vuStageRequests.add(1, tags);

  if (response.status >= 400 || response.status === 0) {
    vuStageErrors.add(1, tags);
  }
}

// [수정] default 함수에서 setup 데이터를 인자로 받음
export default function (setupData) {
  const startTime = setupData.startTime;

  // 1. 게시글 검색 (100%)
  const keyword = data.getRandomKeyword();

  let res = api.searchPosts(keyword);
  recordMetrics(res, startTime); // startTime 전달

  checks.checkSearchResult(res, 'search');

  const searchResult = res.json();
  const posts = searchResult.data?.posts || [];

  sleep(3);

  // 2. 인피니티 스크롤 (80%)
  if (Math.random() < 0.8 && posts.length > 0) {
    let cursor = searchResult.nextCursor;

    for (let page = 2; page <= SCROLL_CONFIG.MAX_PAGES && cursor; page++) {
      res = api.searchPosts(keyword, 20, cursor);
      recordMetrics(res, startTime);
      checks.checkSearchResult(res, `scroll_page${page}`);

      const result = res.json();
      cursor = result.nextCursor;
      sleep(3);
    }
  }

  // 3. 피드 상세 보기 (60%)
  if (Math.random() < 0.6 && posts.length > 0) {
    const randomPost = posts[Math.floor(Math.random() * posts.length)];
    const postId = randomPost.id;

    res = api.getPostDetail(postId);
    recordMetrics(res, startTime);
    checks.checkPostDetail(res, 'post_detail');
    sleep(3);

    // 4. 댓글 작성 (60%)
    if (Math.random() < 0.6) {
      const commentContent = data.generateCommentContent();
      res = api.createComment(postId, commentContent);
      recordMetrics(res, startTime);
      checks.checkCreated(res, 'create_comment');
      sleep(3);
    }
  }

  // 5. 랜덤 게시물에 댓글 작성 (10%) - 피드 작성 대체
  if (Math.random() < 0.1 && posts.length > 0) {
    const randomPost = posts[Math.floor(Math.random() * posts.length)];
    const postId = randomPost.id;

    // 게시물 상세 조회
    res = api.getPostDetail(postId);
    recordMetrics(res, startTime);
    checks.checkPostDetail(res, 'post_detail');
    sleep(3);

    // 댓글 작성
    const commentContent = data.generateCommentContent();
    res = api.createComment(postId, commentContent);
    recordMetrics(res, startTime);
    checks.checkCreated(res, 'create_comment');
    sleep(3);
  }
}

export function handleSummary(data) {
  const vuStages = getVUStages();
  const vuMetrics = {};
  vuStages.forEach(vu => {
    vuMetrics[vu] = { avg: 0, p95: 0, p99: 0, requests: 0, errors: 0 };
  });

  Object.keys(data.metrics).forEach(metricName => {
    // k6 버전에 따라 태그 매칭 방식을 유연하게 처리
    const stageMatch = metricName.match(/vu_stage:(\d+)/);
    if (stageMatch) {
      const vu = parseInt(stageMatch[1]);
      if (!vuMetrics[vu]) return;

      const metric = data.metrics[metricName];
      if (metricName.includes('vu_stage_duration')) {
        vuMetrics[vu].avg = metric.values.avg || 0;
        vuMetrics[vu].p95 = metric.values['p(95)'] || 0;
        vuMetrics[vu].p99 = metric.values['p(99)'] || 0;
      } else if (metricName.includes('vu_stage_requests')) {
        vuMetrics[vu].requests = metric.values.count || 0;
      } else if (metricName.includes('vu_stage_errors')) {
        vuMetrics[vu].errors = metric.values.count || 0;
      }
    }
  });

  let table = '\n\n                           VU 단계별 부하 테스트 결과\n\n';
  table += '='.repeat(100) + '\n';
  table += 'VU      | avg(ms)   | p95(ms)   | p99(ms)   | 요청수       | 에러수       | 에러율\n';
  table += '-'.repeat(100) + '\n';

  vuStages.forEach(vu => {
    const m = vuMetrics[vu];
    if (m.requests > 0) {
      const errorRate = ((m.errors / m.requests) * 100).toFixed(2);
      table += `${String(vu).padEnd(7)} | ${m.avg.toFixed(2).padStart(9)} | ${m.p95.toFixed(2).padStart(9)} | ${m.p99.toFixed(2).padStart(9)} | ${String(m.requests).padStart(12)} | ${String(m.errors).padStart(12)} | ${(errorRate + '%').padStart(7)}\n`;
    }
  });

  table += '='.repeat(100) + '\n';

  return {
    stdout: textSummary(data, { indent: ' ', enableColors: true }) + table,
  };
}