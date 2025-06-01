# 모듈 0: 개발 환경 설정

**완료에 필요한 시간:** 10분

---
**시간이 부족한 경우:** 이미 개발 환경이 설정되어 있다면 이 모듈을 건너뛰어도 됩니다.

---

**사용된 도구:**

* [Docker](https://www.docker.com/)
* [Git](https://git-scm.com/)

이번 모듈에서는 워크샵을 진행하기 위한 개발 환경을 설정합니다. Docker를 사용하여 일관된 개발 환경을 구성하고, 필요한 도구들을 설치합니다.

## 시작하기

### 필수 요구사항

- aws iam 계정
- Docker
- Git


### aws iam 계정 생성

1. 

### 개발 환경 설정

1. 워크샵 레포지토리를 클론합니다:

```sh
git clone https://github.com/dev-coo/aws-cdk-ioc-practice.git
```

2. 스크립트에 실행 권한을 부여합니다:

```sh
chmod +x run-docker.sh
```

3. 개발 환경 도커 이미지를 빌드하고 실행합니다:

```sh
./run-docker.sh
```

### 개발 환경 구성 요소

도커 이미지에는 다음과 같은 도구들이 포함되어 있습니다:

- Python 3.9
- Node.js 18.x
- AWS CLI v2
- AWS CDK

### 설치된 도구 버전 확인

다음 명령어로 설치된 도구들의 버전을 확인할 수 있습니다:

```sh
# AWS CLI 버전 확인
aws --version
# 출력: aws-cli/2.27.7 Python/3.13.2 Linux/5.15.49-linuxkit exe/aarch64.debian.12

# Node.js 버전 확인
node -v
# 출력: v16.20.2

# npm 버전 확인
npm -v
# 출력: 8.19.4

# Python 버전 확인
python --version
# 출력: Python 3.8.20

# AWS CDK 버전 확인
cdk --version
# 출력: 2.1013.0 (build 054afef)
```

이것으로 모듈 0을 마치겠습니다.

[모듈 1 진행](/module-1)