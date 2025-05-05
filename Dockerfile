# Python 3.8 기반 이미지 사용
FROM python:3.8-slim

# 작업 디렉토리 설정
WORKDIR /workspace

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Node.js 설치 (AWS CDK 사용을 위해)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install --location=global aws-cdk

# AWS CLI 설치
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && apt-get install -y unzip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Python 패키지 설치
COPY requirements.txt .
RUN pip install -r requirements.txt

# 볼륨 마운트 포인트 설정
VOLUME ["/workspace"]

# 기본 명령어 설정
CMD ["/bin/bash"] 