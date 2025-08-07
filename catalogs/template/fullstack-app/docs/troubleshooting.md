# 🔧 문제 해결 가이드

## 🚨 자주 발생하는 문제들

### ❌ "AWS credentials not found in workspace variables"

**원인**: Workspace 변수가 설정되지 않음
**해결**:

```bash
1. https://bitbucket.org/coinplugin/workspace/settings 이동
2. Pipelines → Repository variables 확인
3. AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY 재설정
4. ✅ Secured 체크박스 확인
```

### ❌ "Key pair 'xxx' does not exist"

**원인**: EC2 키페어가 해당 리전에 없음
**해결**:

```bash
1. AWS Console → EC2 → Key Pairs 확인
2. 해당 리전(ap-northeast-2)에 키페어 생성
3. 템플릿 실행 시 정확한 키페어 이름 입력
```

### ❌ Pipeline이 시작되지 않음

**원인**: Pipelines가 활성화되지 않음
**해결**:

```bash
1. Bitbucket 저장소 → Pipelines 메뉴
2. "Enable Pipelines" 버튼 클릭
3. 첫 번째 실행이 자동으로 시작됨
```

### ❌ Terraform 권한 오류

**원인**: AWS 권한 부족
**해결**:

```bash
AWS 사용자에게 다음 권한 정책 연결:
- AmazonEC2FullAccess
- AmazonRDSFullAccess
- AmazonVPCFullAccess
- IAMFullAccess (또는 최소 역할 생성 권한)
```

## ✅ 성공 확인 체크리스트

### 1. Pipeline 실행 확인

- [ ] Pipeline 상태가 "SUCCESSFUL"
- [ ] 모든 단계가 초록색
- [ ] "DEPLOYMENT COMPLETED SUCCESSFULLY" 메시지 확인

### 2. AWS 리소스 확인

- [ ] EC2 인스턴스가 "running" 상태
- [ ] RDS 데이터베이스가 "available" 상태
- [ ] Load Balancer가 "active" 상태
- [ ] Security Groups 올바르게 설정

### 3. 애플리케이션 접속 확인

- [ ] Load Balancer URL 접속 가능
- [ ] Frontend 페이지 로딩 성공
- [ ] Backend API `/health` 엔드포인트 응답

### 4. Backstage 등록 확인

- [ ] Catalog에서 프로젝트 확인 가능
- [ ] Component 정보 정상 표시
- [ ] 링크들이 올바르게 연결

## 🔍 디버깅 방법

### Pipeline 로그 확인

```bash
1. Bitbucket → 저장소 → Pipelines
2. 실행 중인 Pipeline 클릭
3. 각 단계별 로그 상세 확인
4. 오류 메시지 검색 및 분석
```

### AWS CloudWatch 로그

```bash
1. AWS Console → CloudWatch → Log groups
2. /aws/ec2/user-data 로그 그룹 확인
3. 인스턴스 초기화 로그 검토
```

### 수동 확인 명령어

```bash
# EC2 인스턴스 상태 확인
aws ec2 describe-instances --region ap-northeast-2 --filters "Name=tag:Name,Values=*your-project*"

# RDS 상태 확인
aws rds describe-db-instances --region ap-northeast-2

# Load Balancer 확인
aws elbv2 describe-load-balancers --region ap-northeast-2
```

## 🆘 긴급 문제 해결

### 비용 절약을 위한 긴급 정지

```bash
# 모든 리소스 즉시 삭제 (주의!)
cd terraform/
terraform destroy -auto-approve
```

### 특정 리소스만 재생성

```bash
# 인스턴스만 재시작
terraform destroy -target=module.ec2.aws_autoscaling_group.main
terraform apply -auto-approve
```

## 📞 지원 요청 시 준비사항

문제 해결을 요청할 때 다음 정보를 준비하세요:

1. **프로젝트 이름**:
2. **Pipeline URL**:
3. **오류 메시지**: (전체 로그)
4. **AWS 리전**:
5. **실행 시간**:

## 🎯 성공률 높이는 팁

### 첫 번째 실행 전

- [ ] AWS 계정 한도 확인 (VPC, EC2 인스턴스)
- [ ] 리전별 키페어 사전 생성
- [ ] Workspace 변수 이중 확인

### Pipeline 실행 중

- [ ] 로그를 실시간으로 모니터링
- [ ] AWS Console에서 리소스 생성 상태 확인
- [ ] 15-20분은 여유있게 대기

### 완료 후

- [ ] 애플리케이션 URL 즉시 테스트
- [ ] Backstage에서 프로젝트 정보 확인
- [ ] 팀원들과 결과 공유
