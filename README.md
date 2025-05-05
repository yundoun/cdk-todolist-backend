# AWS CDK를 이용한 현대적 애플리케이션 구축 실습

이 프로젝트는 AWS CDK를 사용하여 현대적인 웹 애플리케이션을 구축하는 실습 프로젝트입니다. AWS의 다양한 서비스를 활용하여 마이크로서비스 아키텍처를 구현하고, 인프라를 코드로 관리하는 방법을 학습합니다.

## 개발 환경 설정

프로젝트는 Docker를 사용하여 개발 환경을 구성합니다:

```bash
# 실행 권한 부여
chmod +x run-docker.sh

# 개발 환경 도커 이미지 빌드 및 실행
./run-docker.sh
```

개발 환경에는 다음 도구들이 포함되어 있습니다:
- Python 3.9
- Node.js 18.x
- AWS CLI v2
- AWS CDK

## 프로젝트 구조

```
.
├── source/                    # AWS 워크샵 소스 코드
│   ├── module-1/             # 모듈 1: 기본 인프라 설정
│   ├── module-2/             # 모듈 2: Flask 애플리케이션 및 Fargate 배포
│   └── ...
├── cdk/                      # cdk 소스 코드
├── web/                      # 웹 소스 코드
├── app/                      # 애플리케이션 소스 코드
├── Dockerfile                # 개발 환경 도커 설정
├── requirements.txt          # Python 패키지 의존성
└── run-docker.sh            # 도커 실행 스크립트
```

## 주의사항

- AWS 계정과 관리자 권한이 필요합니다
- 일부 AWS 서비스는 비용이 발생할 수 있습니다
- 실습 완료 후 생성된 리소스는 반드시 삭제해야 합니다

## 참고 자료

- [AWS sample](https://github.com/aws-samples/aws-modern-application-workshop)