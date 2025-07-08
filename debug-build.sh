#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Debug build process...${NC}"

# 빌드 컨테이너 시작
echo -e "${BLUE}🚀 Starting build container...${NC}"
docker compose -f docker-compose-build.yml up -d backstage-builder

# 컨테이너 접속하여 단계별 실행
echo -e "${YELLOW}🔧 Entering container for manual debugging...${NC}"
echo -e "${YELLOW}You can now run commands manually:${NC}"
echo -e "${YELLOW}  - yarn install --immutable${NC}"
echo -e "${YELLOW}  - yarn tsc${NC}"
echo -e "${YELLOW}  - yarn build:backend${NC}"
echo -e "${YELLOW}Type 'exit' to leave the container${NC}"

docker compose -f docker-compose-build.yml exec backstage-builder bash

echo -e "${BLUE}🧹 Cleaning up...${NC}"
docker compose -f docker-compose-build.yml down