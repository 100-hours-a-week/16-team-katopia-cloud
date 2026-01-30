// v1 환경에서 테스트 configs
// utils/config.js

// 환경변수에서 설정 로드
export const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
export const TEST_TOKEN = __ENV.TEST_TOKEN || '';

// API 엔드포인트
export const ENDPOINTS = {
  SEARCH: '/api/search/posts',
  POSTS: '/api/posts',
  POST_DETAIL: (id) => `/api/posts/${id}`,
  PRESIGNED_URL: '/api/uploads/presign',
};

// 공통 헤더
export function getHeaders() {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TEST_TOKEN}`,
  };
}

export function getMultipartHeaders() {
  return {
    'Authorization': `Bearer ${TEST_TOKEN}`,
  };
}

// 부하 테스트 설정
export const LOAD_CONFIG = {
  INITIAL_VU: 20,
  MAX_VU: 400,
  RAMP_DURATION: '30s',  // 30초마다
  VU_INCREMENT: 20,       // 20명씩 증가
  STABLE_DURATION: '5m',  // 5분 유지
};

// Thresholds 설정
export const THRESHOLDS = {
  'http_req_duration': ['p(95)<500'],     // p95 < 500ms
  'http_req_failed': ['rate<0.01'],       // 실패율 < 1%
};