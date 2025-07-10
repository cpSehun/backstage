#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Clean build with database reset...${NC}"

# 1. 모든 서비스 중지
echo -e "${BLUE}🛑 Stopping all services...${NC}"
docker compose down

# 2. PostgreSQL 볼륨 삭제 (데이터베이스 초기화)
echo -e "${YELLOW}🗑️  Removing PostgreSQL volumes...${NC}"
docker volume rm $(docker volume ls -q | grep postgres) 2>/dev/null || true

# 3. 빌드 실행
echo -e "${BLUE}🔨 Building application...${NC}"
if docker compose -f docker-compose-build.yml run --rm --user root backstage-builder bash -c "
  echo '📦 Installing dependencies...' &&
  yarn install --immutable &&
  echo '🔧 Compiling TypeScript...' &&
  yarn tsc &&
  echo '🏗️ Building backend...' &&
  yarn build:backend
"; then
    echo -e "${GREEN}✅ Build completed successfully${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# 4. 운영 컨테이너 재빌드 및 시작
echo -e "${BLUE}🔄 Starting fresh containers...${NC}"
docker compose build --no-cache backstage
docker compose up -d

echo -e "${GREEN}✅ Clean deployment completed!${NC}"
echo -e "${YELLOW}📝 Note: Database has been reset. All catalog entities will be re-registered.${NC}"

http://localhost:3001/catalog/default/group/CPLABS
