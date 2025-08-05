# 🚀 ${{ values.name | capitalize }}

${{ values.description }}

이 애플리케이션은 **Backstage**를 통해 생성된 풀스택 웹 애플리케이션입니다.

## 🛠️ 기술 스택

### Frontend

- ⚛️ **Next.js 14** - React 기반 프론트엔드 프레임워크
- 🎨 **TypeScript** - 타입 안전성을 위한 정적 타입 시스템
- 📱 **Responsive Design** - 모바일 친화적 UI

### Backend

- 🐍 **Python 3.11** - 현대적인 파이썬 버전
- ⚡ **FastAPI** - 고성능 비동기 웹 프레임워크
- 🗄️ **SQLAlchemy** - ORM 및 데이터베이스 관리
- 📊 **Structured Logging** - 구조화된 로깅 시스템

### Database

- 🐘 **PostgreSQL 15** - 관계형 데이터베이스
- 🔄 **Alembic** - 데이터베이스 마이그레이션 도구

### Infrastructure

- ☁️ **AWS** - 클라우드 인프라
  - EC2 (컴퓨팅)
  - RDS (데이터베이스)
  - ALB (로드 밸런서)
  - VPC (네트워킹)
- 🏗️ **Terraform** - Infrastructure as Code
- 🐳 **Docker** - 컨테이너화
- 🚀 **Bitbucket Pipeline** - CI/CD 자동화

## 🚀 빠른 시작

### 1. 저장소 클론

```bash
git clone <repository-url>
cd ${{ values.name }}
```

### 2. 환경 변수 설정

```bash
cp .env.example .env
# .env 파일을 편집하여 필요한 값들을 설정하세요
```

### 3. Docker Compose로 로컬 실행

```bash
# 모든 서비스 시작 (PostgreSQL, Backend, Frontend)
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 애플리케이션 접속
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API 문서: http://localhost:8000/docs
```

### 4. 개발 환경 (로컬 개발)

```bash
# 데이터베이스만 Docker로 실행
docker-compose up -d postgres

# Backend 개발 서버 시작
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Frontend 개발 서버 시작 (새 터미널)
cd frontend
npm install
npm run dev
```

## 📚 API 문서

애플리케이션이 실행 중일 때 다음 URL에서 API 문서를 확인할 수 있습니다:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔍 주요 엔드포인트

- `GET /` - API 정보
- `GET /health` - 헬스체크
- `GET /api/status` - 서비스 상태
- `GET /api/logs` - 애플리케이션 로그
- `GET /api/database/info` - 데이터베이스 정보

## 🚢 배포

### AWS 인프라 배포

1. **Bitbucket Pipeline 환경 변수 설정**:

   ```
   AWS_ACCESS_KEY_ID=<your-access-key-id>
   AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
   AWS_KEY_NAME=<your-ec2-key-pair-name>
   DB_PASSWORD=<secure-database-password>
   ```

2. **자동 배포**:

   - `main` 브랜치에 코드를 푸시하면 자동으로 Pipeline이 시작됩니다
   - Infrastructure Planning → Manual Approval → Infrastructure Deployment → Application Deployment

3. **수동 배포**:
   ```bash
   cd terraform
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

### 배포된 리소스

- **VPC**: 격리된 네트워크 환경
- **EC2**: 애플리케이션 서버 (Auto Scaling Group)
- **RDS**: PostgreSQL 데이터베이스 (Multi-AZ)
- **ALB**: 로드 밸런서 (고가용성)
- **보안 그룹**: 네트워크 보안 규칙

## 🔧 개발 가이드

### 프로젝트 구조

```
${{ values.name }}/
├── frontend/                 # Next.js 애플리케이션
│   ├── pages/               # 페이지 컴포넌트
│   ├── components/          # 재사용 가능한 컴포넌트
│   └── styles/              # 스타일 시트
├── backend/                 # FastAPI 애플리케이션
│   ├── main.py             # 메인 애플리케이션
│   ├── models.py           # 데이터베이스 모델
│   └── requirements.txt    # Python 의존성
├── terraform/              # Infrastructure as Code
│   ├── modules/            # Terraform 모듈
│   └── *.tf               # Terraform 설정 파일
├── docker-compose.yml      # 로컬 개발 환경
└── bitbucket-pipelines.yml # CI/CD 파이프라인
```

### 새로운 API 엔드포인트 추가

1. `backend/main.py`에 새 엔드포인트 함수 추가
2. 필요시 `backend/models.py`에 새 데이터베이스 모델 추가
3. API 문서는 자동으로 업데이트됩니다

### 새로운 페이지 추가

1. `frontend/pages/` 디렉토리에 새 `.tsx` 파일 추가
2. Next.js 파일 기반 라우팅이 자동으로 적용됩니다

## 🔍 모니터링 및 로깅

### CloudWatch 로그

- EC2 인스턴스 로그: `/aws/ec2/user-data`
- 애플리케이션 로그: `/aws/ec2/application`

### Backstage 통합

이 애플리케이션은 Backstage에 완전히 통합되어 있습니다:

- 📊 AWS 리소스 모니터링
- 🚀 CI/CD 파이프라인 상태
- 📈 CloudWatch 메트릭
- 📋 API 문서

## 🤝 기여하기

1. 새 브랜치 생성: `git checkout -b feature/amazing-feature`
2. 변경사항 커밋: `git commit -m 'Add some AmazingFeature'`
3. 브랜치에 푸시: `git push origin feature/amazing-feature`
4. Pull Request 생성

## 📞 지원

문제가 발생하거나 질문이 있으시면:

- 📋 [Backstage에서 이슈 생성](${BITBUCKET_REPO_FULL_NAME}/issues)
- 💬 팀 Slack 채널: `#${{ values.name }}`
- 📧 담당자: ${{ values.owner }}

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 LICENSE 파일을 참조하세요.

---

**Created with ❤️ by Backstage Template System**

- 🏗️ Infrastructure: AWS + Terraform
- 🚀 Deployment: Bitbucket Pipeline
- 📊 Monitoring: Backstage + CloudWatch
- 🔧 Region: ${{ values.awsRegion }}
- 💻 Instance: ${{ values.instanceType }}
