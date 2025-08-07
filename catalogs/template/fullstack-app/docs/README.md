# ⚡ 5분 완료 체크리스트

## 📋 지금 바로 실행하세요!

### ✅ **1단계: Workspace 변수 설정** (2분)

```
🔗 https://bitbucket.org/coinplugin/workspace/settings/pipelines/repository-variables

추가할 변수:
□ AWS_ACCESS_KEY_ID = [your-key] (✅ Secured)
□ AWS_SECRET_ACCESS_KEY = [your-secret] (✅ Secured)
□ DEFAULT_KEY_NAME = [your-keypair-name]
```

### ✅ **2단계: 템플릿 파일 교체** (2분)

```
□ catalogs/template/fullstack-app/content/bitbucket-pipelines.yml 교체
□ catalogs/template/fullstack-app/template.yaml 파라미터 업데이트
□ 변경사항 Git 커밋 & 푸시
```

### ✅ **3단계: 테스트 실행** (1분 + 대기)

```
□ Backstage → Create → Full Stack AWS Application
□ 프로젝트 이름: test-app-001
□ Create 버튼 클릭
□ Bitbucket → Pipelines → Enable Pipelines 클릭
□ ☕ 15분 대기
```

## 🎉 **완료 후 확인사항**

### 성공 시 볼 수 있는 것들:

- ✅ Bitbucket Pipeline: "SUCCESSFUL" 상태
- ✅ AWS Console: EC2, RDS, ALB 리소스 생성
- ✅ 웹 애플리케이션: 접속 가능한 URL
- ✅ Backstage: 카탈로그에 자동 등록

### 실패 시 체크할 것들:

- ❌ Workspace 변수 설정 재확인
- ❌ AWS 권한 확인
- ❌ EC2 키페어 존재 확인
- ❌ Pipeline 로그에서 오류 메시지 확인

## 🚀 **다음 단계**

성공적으로 완료되면:

1. 📊 **모니터링**: AWS CloudWatch에서 리소스 상태 확인
2. 🔧 **개발**: 로컬에서 개발 후 Push하면 자동 업데이트
3. 🎯 **확장**: 더 많은 프로젝트에 템플릿 적용
4. 🏢 **팀 공유**: 다른 팀원들에게 사용법 전파

---

## ⏰ **지금 시작하시겠습니까?**

위의 체크리스트를 따라하시면 **정확히 15분 후**에 완전히 동작하는 풀스택 애플리케이션을 AWS에서 확인할 수 있습니다!

궁금한 점이 있으시면 언제든 질문해주세요! 🙋‍♂️
