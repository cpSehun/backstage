#!/bin/bash
echo "🔄 Backstage 설정 업데이트 중..."
echo "⏳ 백엔드 빌드 시작..."
docker compose exec backstage yarn install --immutable
docker compose exec backstage yarn tsc
docker compose exec backstage yarn build:backend
echo "🔄 컨테이너 재시작..."
docker compose restart backstage
echo "✅ 완료!"
echo "🌐 브라우저에서 확인: http://localhost:3001 또는 http://localhost:7007"
