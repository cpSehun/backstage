#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

cd ../../

echo -e "${BLUE}🔨 Simple build (root user)...${NC}"

if docker compose -f docker-compose-build.yml run --rm --user root backstage-builder bash -c "
  echo '📦 Installing dependencies...' &&
  yarn install --immutable &&
  echo '🔧 Compiling TypeScript...' &&
  yarn tsc &&
  echo '🏗️ Building backend...' &&
  yarn build:backend
"; then
    echo -e "${GREEN}✅ Build completed successfully${NC}"
    
    # 운영 컨테이너 재시작
    echo -e "${BLUE}🔄 Restarting production container...${NC}"
    docker compose build --no-cache backstage
    docker compose up -d backstage
    
    echo -e "${GREEN}✅ Deployment completed!${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi