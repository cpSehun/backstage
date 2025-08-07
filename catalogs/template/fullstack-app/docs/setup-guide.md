# 🚀 완전 자동화 사용 가이드

## ✅ 사전 준비 체크리스트

### 1. AWS 준비사항

- [ ] AWS 액세스 키 발급 완료
- [ ] EC2 키페어 생성 완료 (예: `cplabs-common-keypair`)
- [ ] 필요한 AWS 권한 확인 (EC2, RDS, VPC, IAM)

### 2. Bitbucket Workspace 변수 설정 확인

- [ ] `AWS_ACCESS_KEY_ID` (Secured ✅)
- [ ] `AWS_SECRET_ACCESS_KEY` (Secured ✅)
- [ ] `AWS_DEFAULT_REGION`
- [ ] `DEFAULT_KEY_NAME`

## 🎯 실제 사용 절차

### 1️⃣ Backstage에서 템플릿 실행

1. Backstage → `Create...` → `🚀 Full Stack AWS Application`
2. 폼 작성:

   - **프로젝트 이름**: `test-webapp`
   - **설명**: `테스트용 웹 애플리케이션`
   - **소유자**: 본인 팀 선택
   - **프로젝트**: `DEVOPS`
   - **키페어 이름**: `cplabs-common-keypair`
   - **나머지**: 기본값 사용

3. `Create` 버튼 클릭

### 2️⃣ Pipeline 활성화 (한 번만)

1. 생성된 Bitbucket 저장소로 이동
2. 왼쪽 메뉴에서 `Pipelines` 클릭
3. **`Enable Pipelines`** 버튼 클릭
4. 자동으로 첫 번째 Pipeline 실행 시작!

### 3️⃣ 배포 진행 상황 모니터링 (15분)

```
🧪 애플리케이션 빌드 테스트 (2분)
    ↓
🏗️ AWS 인프라 배포 시작 (10분)
    ↓
🐳 애플리케이션 배포 (3분)
    ↓
🎉 배포 완료!
```

### 4️⃣ 결과 확인

Pipeline이 완료되면:

- ✅ **AWS EC2**: Auto Scaling Group + Load Balancer
- ✅ **AWS RDS**: PostgreSQL 데이터베이스
- ✅ **애플리케이션 URL**: Pipeline 로그에 표시
- ✅ **Backstage 카탈로그**: 자동 등록

## 📊 예상 결과

### Pipeline 성공 시 로그:

```
🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉
⭐ Your test-webapp application is ready!
🌐 Application URL: http://test-webapp-alb-xxxxxxx.ap-northeast-2.elb.amazonaws.com
📅 Completed at: Wed Aug 7 15:30:45 UTC 2025
```

### AWS 리소스 생성:

- **VPC**: `test-webapp-vpc`
- **EC2**: `test-webapp-instance` (Auto Scaling)
- **RDS**: `test-webapp-db`
- **ALB**: `test-webapp-alb`

## 🎯 테스트 시나리오

### **첫 번째 테스트:**

1. **간단한 이름**: `hello-world`
2. **기본 설정** 모두 사용
3. **예상 시간**: 총 15분
4. **성공 기준**: 웹페이지 접속 가능

### **실제 프로젝트:**

1. **의미있는 이름**: `user-management-api`
2. **적절한 인스턴스** 선택 (t3.medium)
3. **팀 소유자** 지정
4. **프로덕션 준비** 설정
