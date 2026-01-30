// scenarios/big-load-test.js
import { sleep } from 'k6';
import { THRESHOLDS } from '../configs/v1.js';
import * as api from '../utils/requests.js';
import * as checks from '../utils/checks.js';
import * as data from '../utils/data.js';

// 부하 모델링 설정
export const options = {
  stages: [
    { duration: '30s', target: 50 },   // 30초: 20 -> 40
    { duration: '30s', target: 100 },   // 30초: 40 -> 60
    { duration: '30s', target: 150 },   // 30초: 60 -> 80
    { duration: '30s', target: 200 },  // 30초: 80 -> 100
    { duration: '30s', target: 250 },  // 30초: 100 -> 120
    { duration: '30s', target: 300 },  // 30초: 120 -> 140
    { duration: '30s', target: 350 },  // 30초: 140 -> 160
    { duration: '30s', target: 400 },  // 30초: 160 -> 180
    { duration: '30s', target: 450 },  // 30초: 180 -> 200
    { duration: '30s', target: 500 },  // 30초: 200 -> 220
    { duration: '30s', target: 550 },  // 30초: 220 -> 240
    { duration: '30s', target: 600 },  // 30초: 240 -> 260
    { duration: '30s', target: 650 },  // 30초: 260 -> 280
    { duration: '30s', target: 700 },  // 30초: 280 -> 300
    { duration: '30s', target: 750 },  // 30초: 300 -> 320
    { duration: '30s', target: 800 },  // 30초: 320 -> 340
    { duration: '30s', target: 850 },  // 30초: 340 -> 360
    { duration: '30s', target: 900 },  // 30초: 360 -> 380
    { duration: '30s', target: 950 },  // 30초: 380 -> 400
    { duration: '30s', target: 1000 },   // 30초: 400 -> 420
  ],
  thresholds: THRESHOLDS,
};

export default function () {
  // 1. 게시글 검색 (100%)
  const keyword = data.getRandomKeyword();

  let res = api.searchPosts(keyword);

  checks.checkSearchResult(res, 'search');

  const searchResult = res.json();
  const posts = searchResult.posts || [];
 
  sleep(3);
  
  // 2. 인피니티 스크롤 (80%) - 페이지 2, 3 연속 호출
  if (Math.random() < 0.8 && posts.length > 0) {
    const nextCursor = searchResult.nextCursor;
    
    if (nextCursor) {
      // 페이지 2
      res = api.searchPosts(keyword, 20, nextCursor);
      checks.checkSearchResult(res, 'scroll_page2');
      
      const page2Result = res.json();
      const nextCursor2 = page2Result.nextCursor;
      
      sleep(3);
      
      // 페이지 3
      if (nextCursor2) {
        res = api.searchPosts(keyword, 20, nextCursor2);
        checks.checkSearchResult(res, 'scroll_page3');
        sleep(3);
      }
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
    const accessUrl = presignedData.data.files[0].accessUrl;
    
    sleep(3);
    
    // 4-2. S3에 이미지 업로드
    const imageData = data.getRandomImage();
    res = api.uploadToS3(uploadUrl, imageData);
    checks.checkS3Upload(res, 's3_upload');
    
    sleep(3);
    
    // 4-3. 피드 작성
    const content = data.generatePostContent();
    const imageUrls = [accessUrl];
    const tags = data.generateTags();
    
    res = api.createPost(content, imageUrls, tags);
    checks.checkCreated(res, 'create_post');
    
    sleep(3);
  }
}

