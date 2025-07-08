#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Quick build in Docker...${NC}"

# 빌드 컨테이너에서 빌드 실행
echo -e "${BLUE}📦 Running build in container...${NC}"
if docker compose -f docker-compose-build.yml run --rm backstage-builder bash -c "
  echo '🔧 Setting permissions...' &&
  chown -R node:node /app &&
  echo '📦 Installing dependencies...' &&
  su node -c 'yarn install --immutable' &&
  echo '🔧 Compiling TypeScript...' &&
  su node -c 'yarn tsc' &&
  echo '🏗️ Building backend...' &&
  su node -c 'yarn build:backend' &&
  echo '✅ Build completed in container'
"; then
    echo -e "${GREEN}✅ Container build completed successfully${NC}"
else
    echo -e "${RED}❌ Container build failed${NC}"
    exit 1
fi

# 운영 컨테이너 재빌드 및 재시작
echo -e "${BLUE}🔄 Rebuilding production container...${NC}"
if docker compose build --no-cache backstage && docker compose up -d backstage; then
    echo -e "${GREEN}✅ Production container restarted successfully${NC}"
else
    echo -e "${RED}❌ Failed to restart production container${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed!${NC}"