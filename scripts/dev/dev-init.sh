#!/bin/bash
set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

cd ../../

# 에러 핸들링 함수
handle_error() {
    echo -e "${RED}❌ Error occurred at line $1${NC}"
    echo "🧹 Cleaning up build container..."
    docker compose -f docker-compose-build.yml down 2>/dev/null || true
    exit 1
}

# 에러 트랩 설정
trap 'handle_error $LINENO' ERR

echo -e "${BLUE}🔨 Starting Docker build process...${NC}"

# 1. 빌드 컨테이너 시작
echo -e "${BLUE}🚀 Starting build container...${NC}"
docker compose -f docker-compose-build.yml up -d backstage-builder

# 2. 빌드 실행
echo -e "${BLUE}📦 Installing dependencies...${NC}"
if docker compose -f docker-compose-build.yml exec backstage-builder yarn install --immutable; then
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 Compiling TypeScript...${NC}"
if docker compose -f docker-compose-build.yml exec backstage-builder yarn tsc; then
    echo -e "${GREEN}✅ TypeScript compiled successfully${NC}"
else
    echo -e "${RED}❌ Failed to compile TypeScript${NC}"
    exit 1
fi

echo -e "${BLUE}🏗️ Building backend...${NC}"
if docker compose -f docker-compose-build.yml exec backstage-builder yarn build:backend; then
    echo -e "${GREEN}✅ Backend built successfully${NC}"
else
    echo -e "${RED}❌ Failed to build backend${NC}"
    exit 1
fi

# 3. 컨테이너 재빌드 및 재시작
echo -e "${BLUE}🔄 Rebuilding and restarting dev container...${NC}"
if docker compose build --no-cache  && docker compose up -d ; then
    echo -e "${GREEN}✅ dev container restarted successfully${NC}"
else
    echo -e "${RED}❌ Failed to restart dev container${NC}"
    exit 1
fi

# 4. 빌드 컨테이너 정리
echo -e "${BLUE}🧹 Cleaning up build container...${NC}"
docker compose -f docker-compose-build.yml down

echo -e "${GREEN}✅ Build completed successfully!${NC}"