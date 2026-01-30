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

echo "🚀 k6 부하 테스트 시작..."
echo "📍 BASE_URL: $BASE_URL"
echo ""

# k6 실행 (환경변수 명시적 전달)
k6 run -e BASE_URL="$BASE_URL" -e TEST_TOKEN="$TEST_TOKEN" scenarios/v1-load-test.js

echo ""
echo "✅ 테스트 완료!"