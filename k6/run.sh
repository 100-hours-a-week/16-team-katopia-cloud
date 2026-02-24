#!/bin/bash

# 스크립트가 있는 디렉토리로 이동
cd "$(dirname "$0")"

# .env 파일이 있는지 확인
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다."
    echo "📝 .env.example을 복사하여 .env 파일을 만들어주세요:"
    echo "   cp .env.example .env"
    exit 1
fi

# .env 파일 로드
set -a
source .env
set +a

# 환경변수 확인
if [ -z "$BASE_URL" ]; then
    echo "❌ BASE_URL이 설정되지 않았습니다."
    exit 1
fi

if [ -z "$TEST_TOKEN" ]; then
    echo "❌ TEST_TOKEN이 설정되지 않았습니다."
    exit 1
fi

# 시나리오 선택 (환경변수로 덮어쓰기 가능)
SCENARIO="${SCENARIO:-scenarios/v1-load-test.js}"

if [ ! -f "$SCENARIO" ]; then
    echo "❌ 시나리오 파일을 찾을 수 없습니다: $SCENARIO"
    exit 1
fi

# 마이그레이션 테스트 기본값
if [ -z "$TEST_DURATION" ]; then
    TEST_DURATION="3m"
fi

echo "🚀 k6 부하 테스트 시작..."
echo "📍 BASE_URL: $BASE_URL"
echo "📄 SCENARIO: $SCENARIO"
echo "⏱️ TEST_DURATION: $TEST_DURATION"
echo ""

# k6 실행 (환경변수 명시적 전달)
k6 run \
  -e BASE_URL="$BASE_URL" \
  -e TEST_TOKEN="$TEST_TOKEN" \
  -e TEST_DURATION="$TEST_DURATION" \
  -e TARGET_POST_ID="$TARGET_POST_ID" \
  -e VOTE_IMAGE_OBJECT_KEY="$VOTE_IMAGE_OBJECT_KEY" \
  -e SLEEP_SECONDS="$SLEEP_SECONDS" \
  "$SCENARIO"

echo ""
echo "✅ 테스트 완료!"
