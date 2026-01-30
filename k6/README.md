# k6 부하 테스트

패션 SNS 서비스의 부하 테스트 스크립트입니다.

## 📋 테스트 개요

### 부하 모델링
- **초기 VU**: 20명
- **최대 VU**: 400명
- **부하 증가**: 30초마다 20명씩 증가
- **안정 구간**: 400명 도달 후 5분 유지
- **총 소요 시간**: 약 14.5분

### 테스트 시나리오
1. **게시글 검색** (100%) - 키워드 기반 검색
2. **인피니티 스크롤** (80%) - 페이지 2, 3 연속 호출
3. **피드 상세 보기** (60%) - 검색 결과에서 랜덤 선택
4. **피드 작성** (10%) - Presigned URL → S3 업로드 → 게시글 생성

### 성능 목표
- ✅ 400 VU에서 5분간 시스템 안정성 확인
- ✅ 실패율 < 1%
- ✅ 테스트 API의 p95 < 500ms
- ✅ S3 업로드의 p95 < 1000ms

## 🚀 시작하기

### 1. k6 설치

**macOS**
```bash
brew install k6
```

**Linux**
```bash
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```


### 2. 환경 설정

`.env.example`을 복사하여 `.env` 파일 생성:
```bash
cp .env.example .env
```

`.env` 파일 수정:
```bash
BASE_URL=https://api-dev.yourservice.com
TEST_TOKEN=your_actual_token_here
```

### 3. 테스트 이미지 준비

`images/` 디렉토리에 샘플 이미지 3개 준비:
```
images/
├── sample1.jpg
├── sample2.jpg
└── sample3.jpg
```

### 4. 테스트 데이터 준비

개발 DB에 최소 30개 이상의 게시글이 있어야 합니다.

검색 키워드: `패션`, `스타일`, `코디`

## 📊 실행 방법

### 기본 실행
```bash
k6 run -e BASE_URL=$BASE_URL -e TEST_TOKEN=$TEST_TOKEN scenarios/load-test.js
```

### 결과를 JSON 파일로 저장
```bash
k6 run -e BASE_URL=$BASE_URL -e TEST_TOKEN=$TEST_TOKEN \
  --out json=results/result-$(date +%Y%m%d-%H%M%S).json \
  scenarios/load-test.js
```

### 결과를 InfluxDB로 전송 (선택)
```bash
k6 run -e BASE_URL=$BASE_URL -e TEST_TOKEN=$TEST_TOKEN \
  --out influxdb=http://localhost:8086/k6 \
  scenarios/load-test.js
```

## 📁 디렉토리 구조
```
k6/
├── scenarios/
│   └── load-test.js          # 메인 부하 테스트 시나리오
├── utils/
│   ├── config.js             # 환경 설정
│   ├── requests.js           # API 요청 함수
│   ├── checks.js             # 응답 검증 로직
│   └── data.js               # 테스트 데이터
├── images/
│   ├── sample1.jpg
│   ├── sample2.jpg
│   └── sample3.jpg
├── results/                  # 테스트 결과 (gitignore)
├── .env.example
└── README.md
```

## 📈 결과 해석

### 주요 메트릭

**http_req_duration**: API 응답 시간
- `p(95)`: 95%의 요청이 이 시간 이내
- 목표: p(95) < 500ms

**http_req_failed**: 실패율
- 목표: < 1% (0.01)

**http_reqs**: 초당 요청 수 (TPS)

**vus**: 가상 사용자 수

### 성공 기준
```
✓ http_req_duration..............: avg=250ms  p(95)=450ms
✓ http_req_failed................: 0.5%
✓ http_reqs......................: 5000/s
✓ vus............................: 400
```

### 실패 예시
```
✗ http_req_duration..............: avg=600ms  p(95)=1200ms  ← 목표 초과
✗ http_req_failed................: 2.5%  ← 실패율 높음
```

## 🔧 문제 해결

### 토큰 만료 에러
```
✗ search: status is 200
  ↳ 0% — ✓ 0 / ✗ 1234
```
→ `.env` 파일의 `TEST_TOKEN` 갱신 필요

### 이미지 로드 실패
```
ERRO[0000] open images/sample1.jpg: no such file or directory
```
→ `images/` 디렉토리에 샘플 이미지 추가

### 검색 결과 없음 경고
```
WARN[0030] no posts found in search result
```
→ 개발 DB에 게시글 데이터 추가 (키워드: 패션, 스타일, 코디)

### S3 업로드 실패
```
✗ s3_upload: status is 200 or 204
```
→ Presigned URL 유효시간 확인 또는 S3 권한 확인

## ⚠️ 주의사항

1. **개발 서버에서만 실행**
   - 운영 서버에서 절대 실행하지 마세요
   - 실제 사용자에게 영향을 줄 수 있습니다

2. **테스트 후 데이터 정리**
   - S3에 테스트 이미지가 쌓입니다 (약 200개)
   - 테스트 후 정리 스크립트 실행 권장

3. **비용 발생**
   - S3 PUT 요청 비용
   - 스토리지 비용
   - CloudFront 트래픽 비용

4. **토큰 보안**
   - `.env` 파일은 절대 커밋하지 마세요
   - `.gitignore`에 포함되어 있는지 확인

## 📝 API 명세

테스트에 사용되는 API:

- `GET /api/search/posts` - 게시글 검색
- `GET /api/posts` - 피드 목록 조회
- `GET /api/posts/{id}` - 피드 상세 조회
- `POST /api/uploads/presign` - Presigned URL 발급
- `PUT {presignedUrl}` - S3 이미지 업로드
- `POST /api/posts` - 피드 작성

## 🔗 참고 자료

- [k6 공식 문서](https://k6.io/docs/)
- [k6 Thresholds](https://k6.io/docs/using-k6/thresholds/)
- [k6 Metrics](https://k6.io/docs/using-k6/metrics/)