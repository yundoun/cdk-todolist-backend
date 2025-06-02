# 모듈 0: 개발 환경 설정

모든 샘플을 통틀어 직접 따라 진행해야하는 부분입니다.
만약 혼자서 iam 설정을 하실줄 아신다면
AdministratorAccess 권한을 가진 계정을 생성하고 진행해주세요.

### aws iam 계정 생성

1. 액세스 관리 -> 사용자 -> 사용자 생성을 누릅니다.
2. 사용자 이름은 cdk로 생성하며 선택사항은 누르지 않고 다음버튼을 누릅니다.
3. 직접 정책 연결에서 AdministratorAccess 권한을 선택하고 다음버튼을 누릅니다.
4. 다음 바로 사용자 생성을 누릅니다.
5. 생성한 사용자창으로 들어가서 액세스 키 만들기를 누릅니다.
6. command line interface(cli) 를 선택하고 다음버튼을 누릅니다.
7. 설명 태그 값은 cdk-sample로 작성하고 액세스키 만들기를 누릅니다.
8. 생성된 액세스키와 비밀액세스키를 저장, 또는 .csv 파일을 저장하고 완료를 누릅니다.

## aws cli 로그인

```sh
aws configure
AWS Access Key ID [None]: 액세스키
AWS Secret Access Key [None]: 비밀액세스키
Default region name [None]: ap-northeast-2
Default output format [None]: json
```


이것으로 모듈 0을 마치겠습니다.

[모듈 1 진행](../module-1/README.md)