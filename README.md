[Docker 환경 for prod]

1. nvm install lts/iron
2. npm install -g yarn
3. npx @backstage/create-app@latest
4. cd backstage
5. softwareupdate --install-rosetta
6. xcode-select --install
7. npm install -g node-gyp(isolated-vm)
8. yarn install --immutable
9. yarn tsc
10. yarn build:backend
11. vi Dockerfile
12. docker image build . -f packages/backend/Dockerfile --tag backstage
13. docker-compose up -d

Front 코드 수정 후 docker-compose up --build -d backstage
Backend 코드 수정후 docker-compose restart backstage

[Local 환경 for dev]

1. nvm install lts/iron
2. npm install -g yarn
3. npx @backstage/create-app@latest
4. cd backstage
5. softwareupdate --install-rosetta
6. xcode-select --install
7. npm install -g node-gyp(isolated-vm)
8. yarn install --immutable
9. yarn add dotenv
10. yarn install
11. nohup yarn start > backstage-app.log 2>&1 &

[Local pm2 실행]
npm install -g pm2 //pm2 설치
pm2 start ecosytem.config.js