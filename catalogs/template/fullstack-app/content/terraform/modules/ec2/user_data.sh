#!/bin/bash
set -e

# 로그 파일 설정
LOG_FILE="/var/log/user-data.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "$(date): Starting user data script"

# 시스템 업데이트
echo "$(date): Updating system packages"
apt-get update -y
apt-get upgrade -y

# 필수 패키지 설치
echo "$(date): Installing essential packages"
apt-get install -y curl wget unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Docker 설치
echo "$(date): Installing Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker 서비스 시작 및 활성화
echo "$(date): Starting Docker service"
systemctl start docker
systemctl enable docker
usermod -a -G docker ubuntu

# Docker Compose 설치
echo "$(date): Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# AWS CLI 설치
echo "$(date): Installing AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# CloudWatch Agent 설치
echo "$(date): Installing CloudWatch Agent"
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# SSM Agent 설치 (Ubuntu 24.04에는 기본 설치되어 있지 않을 수 있음)
echo "$(date): Installing SSM Agent"
snap install amazon-ssm-agent --classic
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service

# 애플리케이션 디렉토리 생성
echo "$(date): Creating application directory"
mkdir -p /opt/app
cd /opt/app

# 환경 변수 파일 생성
echo "$(date): Creating environment variables file"
cat > .env << EOF
# Database Configuration
DATABASE_URL=postgresql://${db_username}:${db_password}@${rds_endpoint}:5432/${db_name}
POSTGRES_HOST=${rds_endpoint}
POSTGRES_PORT=5432
POSTGRES_DB=${db_name}
POSTGRES_USER=${db_username}
POSTGRES_PASSWORD=${db_password}

# Application Configuration
NODE_ENV=production
PYTHONPATH=/app
NEXT_PUBLIC_API_URL=http://localhost:8000

# Logging
LOG_LEVEL=info
EOF

# Docker Compose 설정 파일 생성 (배포용)
echo "$(date): Creating Docker Compose configuration"
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  frontend:
    image: placeholder-frontend:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=http://localhost:8000
    restart: unless-stopped
    depends_on:
      - backend

  backend:
    image: placeholder-backend:latest
    ports:
      - "8000:8000"
    env_file:
      - .env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx reverse proxy (optional)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
EOF

# Nginx 설정 파일 생성
echo "$(date): Creating Nginx configuration"
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }
    
    upstream backend {
        server backend:8000;
    }
    
    server {
        listen 80;
        
        # Frontend routes
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Backend API routes
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /health {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /docs {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# 파일 권한 설정
echo "$(date): Setting file permissions"
chown -R ubuntu:ubuntu /opt/app
chmod +x /opt/app

# 배포 준비 완료 표시
echo "$(date): Creating deployment ready marker"
touch /opt/app/.deployment-ready

# CloudWatch Agent 기본 설정
echo "$(date): Configuring CloudWatch Agent"
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/user-data",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/opt/app/logs/*.log",
                        "log_group_name": "/aws/ec2/application",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
EOF

# CloudWatch Agent 시작
echo "$(date): Starting CloudWatch Agent"
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "$(date): User data script completed successfully"
echo "$(date): EC2 instance ready for application deployment"
echo "$(date): Deployment files are ready at /opt/app"
