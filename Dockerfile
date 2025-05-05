# Python 3.8 기반 이미지 사용 (ARM64용)
FROM --platform=linux/arm64 python:3.8-slim

# 작업 디렉토리 설정
WORKDIR /workspace

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Node.js 설치 (AWS CDK 사용을 위해)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install --location=global aws-cdk

# AWS CLI 설치 (아키텍처에 맞게 수정)
RUN apt-get update && apt-get install -y \
    unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install -r requirements.txt

# 볼륨 마운트 포인트 설정
VOLUME ["/workspace"]

# 기본 명령어 설정
CMD ["/bin/bash"] 