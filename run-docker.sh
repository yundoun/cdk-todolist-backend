#!/bin/bash

# 이미지 빌드
docker build -t aws-workshop-env .

# 컨테이너 실행
docker run -it \
    --name aws-workshop \
    -v "$(pwd):/workspace" \
    -v "$HOME/.aws:/root/.aws" \
    aws-workshop-env 