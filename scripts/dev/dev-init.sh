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

# --- 1단계: 의존성 설치 및 백엔드 빌드 ---
echo -e "${YELLOW}⚠️ Step 1: Installing dependencies and building the backend...${NC}"

# 빌드 컨테이너 시작
docker compose -f docker-compose-build.yml up -d backstage-builder

# --user root 플래그를 추가하여 root 권한으로 yarn 명령어를 실행합니다.
echo -e "${BLUE}📦 Installing dependencies and generating lock file...${NC}"
if docker compose -f docker-compose-build.yml exec --user root backstage-builder yarn install; then
    echo -e "${GREEN}✅ Dependencies installed and lock file generated successfully.${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies.${NC}"
    exit 1
fi

# TypeScript 컴파일
echo -e "${BLUE}🔧 Compiling TypeScript...${NC}"
if docker compose -f docker-compose-build.yml exec --user root backstage-builder yarn tsc; then
    echo -e "${GREEN}✅ TypeScript compiled successfully.${NC}"
else
    echo -e "${RED}❌ Failed to compile TypeScript.${NC}"
    exit 1
fi

# 백엔드 빌드
echo -e "${BLUE}🏗️ Building backend...${NC}"
if docker compose -f docker-compose-build.yml exec --user root backstage-builder yarn build:backend; then
    echo -e "${GREEN}✅ Backend built successfully.${NC}"
else
    echo -e "${RED}❌ Failed to build backend.${NC}"
    exit 1
fi

# 빌드 컨테이너 정리
docker compose -f docker-compose-build.yml down

# --- 2단계: 최종 컨테이너 재빌드 및 재시작 ---
echo -e "\n${BLUE}🔄 Step 2: Rebuilding and restarting the final dev container...${NC}"
echo -e "${YELLOW}Using the newly generated yarn.lock and backend build to create the final image...${NC}"

# 기존 컨테이너 완전 삭제
docker compose down --volumes

# 최종 이미지 빌드 및 컨테이너 시작
if docker compose build --no-cache && docker compose up -d; then
    echo -e "${GREEN}✅ Dev container restarted successfully!${NC}"
else
    echo -e "${RED}❌ Failed to restart dev container.${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Build completed successfully!${NC}"
echo -e "\n${YELLOW}💡 REMINDER: The 'yarn.lock' file has been updated. Please commit it to Git!${NC}"
