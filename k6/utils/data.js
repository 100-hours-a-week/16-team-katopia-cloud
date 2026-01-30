// 테스트 데이터 생성
// utils/data.js

// 검색 키워드 (고정 3개)
const KEYWORDS = ['#패션', '#스타일', '#코디'];

// 랜덤 키워드 선택
export function getRandomKeyword() {
  return KEYWORDS[Math.floor(Math.random() * KEYWORDS.length)];
}

// 샘플 이미지 파일 경로
const SAMPLE_IMAGES = [
  '../images/sample1.jpg',
  '../images/sample2.jpg',
  '../images/sample3.jpg',
  // '../images/sample4.jpg',
  // '../images/sample5.jpg',
];

// ⭐ init 단계에서 이미지를 미리 로드 (파일 최상단에서 실행)
const IMAGE_DATA = SAMPLE_IMAGES.map(path => open(path, 'b'));

// 랜덤 이미지 바이너리 가져오기
export function getRandomImage() {
  const randomIndex = Math.floor(Math.random() * IMAGE_DATA.length);
  return IMAGE_DATA[randomIndex];
}

// 테스트용 게시글 콘텐츠 생성
export function generatePostContent() {
  const timestamp = Date.now();
  const randomStr = Math.random().toString(36).substring(2, 8);
  return `부하 테스트용 게시글입니다. ${timestamp}_${randomStr}`;
}

// 테스트용 태그 생성 (검색 키워드 활용)
export function generateTags() {
  const numTags = Math.floor(Math.random() * 2) + 1; // 1~2개
  const tags = [];
  
  for (let i = 0; i < numTags; i++) {
    tags.push(getRandomKeyword());
  }
  
  return tags;
}