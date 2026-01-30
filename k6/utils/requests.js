// API 요청 함수
// utils/requests.js
import http from 'k6/http';
import { BASE_URL, ENDPOINTS, getHeaders } from '../configs/v1.js';

// 1. Presigned URL 발급 (이미지 1개 기준)
export function getPresignedUrl() {
  const payload = JSON.stringify({
    category: 'POST',
    extensions: ['jpg']
  });
  
  return http.post(
    `${BASE_URL}${ENDPOINTS.PRESIGNED_URL}`,
    payload,
    { 
      headers: getHeaders(),
      tags: { name: 'presigned_url' }
    }
  );
}

// 2. S3 직접 업로드
export function uploadToS3(uploadUrl, imageData) {
  return http.put(
    uploadUrl,
    imageData,
    {
      headers: { 'Content-Type': 'image/jpeg' },
      tags: { name: 's3_upload' }
    }
  );
}

// 3. 피드 작성
export function createPost(content, imageUrls, tags) {
  const payload = JSON.stringify({
    content: content,
    imageUrls: imageUrls,
    tags: tags
  });
  
  return http.post(
    `${BASE_URL}${ENDPOINTS.POSTS}`,
    payload,
    { 
      headers: getHeaders(),
      tags: { name: 'create_post' }
    }
  );
}

// 4. 게시글 검색 (커서 기반 페이징)
export function searchPosts(query, size = 20, after = null) {
  let url = `${BASE_URL}${ENDPOINTS.SEARCH}?query=${encodeURIComponent(query)}&size=${size}`;
  
  if (after) {
    url += `&after=${encodeURIComponent(after)}`;
  }
  
  return http.get(url, { 
    headers: getHeaders(),
    tags: { name: 'search_posts' }
  });
}

// 5. 피드 목록 조회 (커서 기반 페이징)
export function getPostList(cursor = null) {
  let url = `${BASE_URL}${ENDPOINTS.POSTS}`;
  
  if (cursor) {
    url += `?cursor=${encodeURIComponent(cursor)}`;
  }
  
  return http.get(url, { 
    headers: getHeaders(),
    tags: { name: 'get_post_list' }
  });
}

// 6. 피드 상세 조회
export function getPostDetail(postId) {
  return http.get(
    `${BASE_URL}${ENDPOINTS.POST_DETAIL(postId)}`,
    { 
      headers: getHeaders(),
      tags: { name: 'get_post_detail' }
    }
  );
}