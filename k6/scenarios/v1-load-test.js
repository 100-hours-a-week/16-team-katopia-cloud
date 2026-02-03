// scenarios/load-test.js
import { sleep } from 'k6';
import { THRESHOLDS, LOAD_CONFIG, SCROLL_CONFIG } from '../configs/v1.js';
import * as api from '../utils/requests.js';
import * as checks from '../utils/checks.js';
import * as data from '../utils/data.js';

// 부하 모델링 설정
function generateStages() {
  const stages = [];
  for (let vu = LOAD_CONFIG.INITIAL_VU; vu <= LOAD_CONFIG.MAX_VU; vu += LOAD_CONFIG.VU_INCREMENT) {
    stages.push({ duration: LOAD_CONFIG.RAMP_DURATION, target: vu });
  }
  // 마지막에 유지 단계 추가
  stages.push({ duration: LOAD_CONFIG.STABLE_DURATION, target: LOAD_CONFIG.MAX_VU });
  return stages;
}

export const options = {
  stages: generateStages(),
  thresholds: THRESHOLDS,
};

export default function () {
  // 1. 게시글 검색 (100%)
  const keyword = data.getRandomKeyword();

  let res = api.searchPosts(keyword);

  checks.checkSearchResult(res, 'search');

  const searchResult = res.json();
  const posts = searchResult.data?.posts || [];
  
   sleep(3);
  
  // 2. 인피니티 스크롤 (80%) - 페이지 2, 3 연속 호출
  if (Math.random() < 0.8 && posts.length > 0) {
    const cursor = searchResult.nextCursor;
    
    for (let page = 2; page <= SCROLL_CONFIG.MAX_PAGES && cursor; page++) {
      res = api.searchPosts(keyword, 20, cursor);
      checks.checkSearchResult(res, `scroll_page${page}`);
      
      const result = res.json();
      cursor = result.nextCursor;
      
      sleep(3);
    }
  }
  
  // 3. 피드 상세 보기 (60%)
  if (Math.random() < 0.6 && posts.length > 0) {
    // 검색 결과에서 랜덤 게시글 선택
    const randomPost = posts[Math.floor(Math.random() * posts.length)];
    const postId = randomPost.id;
    
    res = api.getPostDetail(postId);
    checks.checkPostDetail(res, 'post_detail');
    sleep(3);

    // 4. 댓글 작성 (60%) - 상세보기한 피드에 댓글 작성
    if (Math.random() < 0.6) {
      const commentContent = data.generateCommentContent();
      res = api.createComment(postId, commentContent);
      checks.checkCreated(res, 'create_comment');
      sleep(3);
    }
  }
  
  // 4. 피드 작성 (10%) - 이미지 업로드 포함
  if (Math.random() < 0.1) {
    // 4-1. Presigned URL 발급
    res = api.getPresignedUrl();
    
    if (res.status !== 200) {
      sleep(3);
      return;
    }
    
    const presignedData = res.json();
    
    // data.files 배열 확인
    if (!presignedData.data || !presignedData.data.files || presignedData.data.files.length === 0) {
      sleep(3);
      return;
    }
    
    const uploadUrl = presignedData.data.files[0].uploadUrl;
    const imageObjectKey = presignedData.data.files[0].imageObjectKey;
    
    sleep(3);
    
    // 4-2. S3에 이미지 업로드
    const imageData = data.getRandomImage();
    res = api.uploadToS3(uploadUrl, imageData);
    checks.checkS3Upload(res, 's3_upload');
    
    sleep(3);
    
    // 4-3. 피드 작성
    const content = data.generatePostContent();
    const imageObjectKeys = [imageObjectKey];
    const tags = data.generateTags();
    
    res = api.createPost(content, imageObjectKeys, tags);
    checks.checkCreated(res, 'create_post');
    
    sleep(3);
  }
}

