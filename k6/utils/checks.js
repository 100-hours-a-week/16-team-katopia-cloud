// 공통 검증 로직
// utils/checks.js
import { check } from 'k6';

// 기본 성공 체크 (200번대 응답)
export function checkSuccess(response, name = 'request') {
  return check(response, {
    [`${name}: status is 2xx`]: (r) => r.status >= 200 && r.status < 300,
  });
}

// 201 Created 체크 (피드 작성용)
export function checkCreated(response, name = 'create_post') {
  return check(response, {
    [`${name}: status is 201`]: (r) => r.status === 201,
    [`${name}: has id`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && body.data.id !== undefined;
      } catch (e) {
        return false;
      }
    },
  });
}

// 200 OK 체크
export function checkOK(response, name = 'request') {
  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
  });
}

// 응답 시간 체크
export function checkResponseTime(response, maxMs = 500, name = 'request') {
  return check(response, {
    [`${name}: response time < ${maxMs}ms`]: (r) => r.timings.duration < maxMs,
  });
}

// 검색 결과 체크
export function checkSearchResult(response, name = 'search') {
  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: has posts array`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && Array.isArray(body.data.posts);
      } catch (e) {
        return false;
      }
    },
  });
}

// 피드 목록 체크
export function checkPostList(response, name = 'post_list') {
  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: has posts array`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && Array.isArray(body.data.posts);
      } catch (e) {
        return false;
      }
    },
    [`${name}: has nextCursor`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && body.data.nextCursor !== undefined;
      } catch (e) {
        return false;
      }
    },
  });
}

// 피드 상세 체크
export function checkPostDetail(response, name = 'post_detail') {
  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: has imageUrls`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && Array.isArray(body.data.imageUrls);
      } catch (e) {
        return false;
      }
    },
    [`${name}: has author`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && body.data.author !== undefined;
      } catch (e) {
        return false;
      }
    },
  });
}

// Presigned URL 체크
export function checkPresignedUrl(response, name = 'presigned_url') {
  return check(response, {
    [`${name}: status is 200`]: (r) => r.status === 200,
    [`${name}: has files array`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return Array.isArray(body.files) && body.files.length > 0;
      } catch (e) {
        return false;
      }
    },
    [`${name}: has uploadUrl and accessUrl`]: (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.files[0].uploadUrl && body.files[0].accessUrl;
      } catch (e) {
        return false;
      }
    },
  });
}

// S3 업로드 체크
export function checkS3Upload(response, name = 's3_upload') {
  return check(response, {
    [`${name}: status is 200 or 204`]: (r) => r.status === 200 || r.status === 204,
  });
}

// 복합 체크 (성공 + 응답시간)
export function checkBasic(response, name = 'request', maxMs = 500) {
  return check(response, {
    [`${name}: status is 2xx`]: (r) => r.status >= 200 && r.status < 300,
    [`${name}: response time < ${maxMs}ms`]: (r) => r.timings.duration < maxMs,
  });
}