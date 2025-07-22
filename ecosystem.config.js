// ecosystem.config.js
module.exports = {
  apps: [
    {
      // pm2에서 관리할 프로세스 이름
      name: 'backstage',

      // 실행할 스크립트 (yarn을 직접 실행)
      script: 'yarn',

      // yarn에 전달할 인자
      args: 'start',

      // 스크립트 인터프리터 (yarn은 셸 스크립트이므로 'none'으로 설정)
      interpreter: 'none',

      // 개발 환경에서 유용: 파일 변경 시 자동으로 앱 재시작
      watch: true,

      // 앱 재시작 시 이전 환경 변수 유지
      preserve_env: true,

      // 로그 파일 경로 설정
      output: './logs/pm2-out.log',
      error: './logs/pm2-error.log',

      // 로그에 타임스탬프 추가
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',

      // 앱이 비정상적으로 종료될 때 재시작하지 않음 (개발 시 권장)
      autorestart: false,
    },
  ],
};
