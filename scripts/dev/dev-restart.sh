#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cd ../../
# 1. 모든 서비스 중지
echo -e "${BLUE}🛑 Stopping all services...${NC}"
docker compose down backstage

# 2. 운영 컨테이너 재빌드 및 시작
echo -e "${BLUE}🔄 Starting fresh containers...${NC}"
docker compose up -d backstage

echo -e "${GREEN}✅ Clean deployment completed!${NC}"
echo -e "${YELLOW}📝 Note: Database has been reset. All catalog entities will be re-registered.${NC}"

