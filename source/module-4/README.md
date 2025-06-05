# 모듈 4: Amazon API Gateway와 AWS Cognito로 사용자 및 API 기능 추가

![Architecture](/images/module-4/architecture-module-4.png)

**완료에 필요한 시간:** 60분

---
**시간이 부족한 경우:** `module-4/cdk`에 있는 완전한 레퍼런스 AWS CDK 코드를 참고하세요

---

**사용된 서비스:**
* [Amazon Cognito](http://aws.amazon.com/cognito/)
* [Amazon API Gateway](https://aws.amazon.com/api-gateway/)
* [Amazon Simple Storage Service (S3)](https://aws.amazon.com/s3/)

### 개요

TodoList 웹사이트에 사용자가 할일을 완료 상태로 토글하고, 삭제하는 것과 같은 더 중요한 기능을 추가하기 위해서는 먼저 웹사이트에 사용자 등록을 가능하게 해야합니다. 웹사이트 사용자의 등록 및 인증을 위해 완전히 관리되는 사용자 자격 증명 관리 서비스인 [**AWS Cognito**](http://aws.amazon.com/cognito/)에서 [**User Pool**](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)을 생성합니다.

등록된 사용자만 할일을 완료하고 삭제할 수 있도록 하고 싶으므로, Fargate에서 동작중인 Flask 웹 앱에서 해당하는 경로에 대한 접근을 제한하려고 합니다. 현재 Fargate 서비스가 사용하는 Network Load Balancer (NLB)는 요청 권한 헤더의 유효성 검사를 지원하지 않습니다. 이를 위해 몇 가지 옵션이 있습니다: [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)로 전환하여 Flask 웹 앱이 권한 부여 헤더를 확인하게 하거나, [Amazon API Gateway](https://aws.amazon.com/api-gateway/)를 사용할 수 있습니다.

Amazon API Gateway는 SSL 종료, CORS, 요청 권한 부여, 조정(throttling), API 단계 및 버전 관리 등과 같은 기본적으로 필요한 REST API 기능을 제공합니다. 이러한 이유로 NLB 앞에 API Gateway를 배포하도록 하겠습니다.

API Gateway는 HTTPS 및 CORS 지원 뿐만 아니라, Cognito User Pool과 통합하여 요청의 권한 부여 유효성 검사도 제공합니다. `/todos/{id}/toggle`와 `/todos/{id}` (DELETE) API 엔드포인트에는 인증된 사용자만 접근할 수 있도록 접근을 제한하겠습니다.

그런 다음 API Gateway는 트래픽을 NLB로 전달하여 Fargate에서 실행되는 Flask 웹 앱에서 처리되게끔 합니다.

### 웹사이트 사용자를 위한 User Pool 추가

#### Cognito User Pool 생성

모든 TodoList 방문자의 정보가 저장될 **Cognito User Pool**을 생성하기 위해, Cognito 스택을 정의할 새로운 TypeScript 파일을 만들겠습니다:

```sh
cd ~/environment/workshop/cdk
touch lib/cognito-stack.ts
```

`cognito-stack.ts`파일을 열고 다음 스택 템플릿을 정의합니다:

```typescript
import * as cdk from 'aws-cdk-lib';

export class CognitoStack extends cdk.Stack {

  constructor(scope: cdk.App, id: string) {
    super(scope, id);
  }
}
```

파일 맨 위에 AWS Cognito CDK 라이브러리에 대한 import 문을 추가합니다:

```typescript
import * as cognito from 'aws-cdk-lib/aws-cognito';
```

생성자 구문 바로 앞에 다음 퍼블릭 속성을 정의합니다:

```typescript
public readonly userPool: cognito.UserPool;
public readonly userPoolClient: cognito.UserPoolClient;
```

이제 _(`super(scope, id);` 구문 다음의)_ 생성자 안에서 Amazon Cognito UserPool을 정의합니다:

```typescript
this.userPool = new cognito.UserPool(this, 'UserPool', {
  userPoolName: 'TodoListUserPool',
  selfSignUpEnabled: true,
  autoVerify: {
    email: true
  }
});
```

위 코드는 Cognito UserPool을 생성하고 풀에 등록된 모든 사용자가 인증된 사용자가 되기 전 인증용 이메일을 통해 자동으로 이메일 주소를 인증받도록 정의합니다.

마지막으로 수행해야할 작업은 웹 애플리케이션이 사용할 Amazon Cognito User Pool Client를 정의하는 것입니다.

다시 _(the super(scope, id); 구문 다음의)_ 생성자 내에서 Amazon Cognito UserPool Client를 정의합니다:

```typescript
this.userPoolClient = new cognito.UserPoolClient(this, 'UserPoolClient', {
  userPool: this.userPool,
  userPoolClientName: 'TodoListUserPoolClient'
});
```

`cdk.CfnOutput` 구문을 정의하는 사용자 정의 출력 속성을 정의하여 생성된 CloudFormation 템플릿이 Cognito User Pool ID와 Cognito User Pool Client ID를 제공하도록 할 수 있습니다. Cognito User Pool ID와 Cognito User Pool Client ID에 대해 `cdk.CfnOutput`을 선언합니다:

```typescript
new cdk.CfnOutput(this, "CognitoUserPool", {
  description: "The Cognito User Pool",
  value: this.userPool.userPoolId
});

new cdk.CfnOutput(this, "CognitoUserPoolClient", {
  description: "The Cognito User Pool Client",
  value: this.userPoolClient.userPoolClientId
});
```

이걸로 `cognito_stack.ts` 파일은 다음과 같아야합니다:

```typescript
import * as cdk from 'aws-cdk-lib';
import * as cognito from 'aws-cdk-lib/aws-cognito';

export class CognitoStack extends cdk.Stack {

  public readonly userPool: cognito.UserPool;
  public readonly userPoolClient: cognito.UserPoolClient;
  
  constructor(scope: cdk.App, id: string) {
    super(scope, id);
    
    this.userPool = new cognito.UserPool(this, 'UserPool', {
      userPoolName: 'TodoListUserPool',
      autoVerify: {
        email: true
      }
    });
    
    this.userPoolClient = new cognito.UserPoolClient(this, 'UserPoolClient', {
      userPool: this.userPool,
      userPoolClientName: 'TodoListUserPoolClient'
    });
    
    new cdk.CfnOutput(this, "CognitoUserPool", {
      description: "The Cognito User Pool",
      value: this.userPool.userPoolId
    });
    
    new cdk.CfnOutput(this, "CognitoUserPoolClient", {
      description: "The Cognito User Pool Client",
      value: this.userPoolClient.userPoolClientId
    });
  }
}
```

Amazon Cognito 리소스를 정의하였습니다. 이제 `cdk.ts` 부트스트랩 파일에 추가하겠습니다.

`cdk.ts` 파일 상단에 다음의 `import`문을 삽입하여 새로운 `CognitoStack` 정의를 추가합니다:

```typescript
import { CognitoStack } from '../lib/cognito-stack';
```

`cdk.ts` 파일 끝에 다음 정의를 삽입합니다:

```typescript
const cognito = new CognitoStack(app,  "TodoList-Cognito");
```

지금까지 완료를하면 `bin/cdk.ts` 파일은 다음처럼 보여야합니다:

```typescript
#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { WebApplicationStack } from "../lib/web-application-stack";
import { NetworkStack } from "../lib/network-stack";
import { EcrStack } from "../lib/ecr-stack";
import { EcsStack } from "../lib/ecs-stack";
import { CiCdStack } from "../lib/cicd-stack";
import { DynamoDbStack } from '../lib/dynamodb-stack';
import { CognitoStack } from '../lib/cognito-stack';

const app = new cdk.App();
new WebApplicationStack(app, "TodoList-Website");
const networkStack = new NetworkStack(app, "TodoList-Network");
const ecrStack = new EcrStack(app, "TodoList-ECR");
const ecsStack = new EcsStack(app, "TodoList-ECS", {
  vpc: networkStack.vpc,
  ecrRepository: ecrStack.ecrRepository
});
new CiCdStack(app, "TodoList-CICD", {
    ecrRepository: ecrStack.ecrRepository,
    ecsService: ecsStack.ecsService.service
});
const dynamoDbStack = new DynamoDbStack(app, "TodoList-DynamoDB", {
    vpc: networkStack.vpc,
    fargateService: ecsStack.ecsService.service
});
const cognito = new CognitoStack(app,  "TodoList-Cognito");
```

이제 Cognito 리소스를 배포합니다:

```sh
cdk deploy TodoList-Cognito
```

이전 명령의 출력에서 Cognito User Pool ID와 the Cognito User Pool Client ID를 기록해둡니다. 이후 단계에서 필요합니다.

### Amazon API Gateway로 새 REST API 추가

#### API Gateway VPC Link 생성

API Gateway가 NLB와 통신할 수 있도록 하기 위해, API Gateway VPC Link를 생성해야 합니다. VPC Link를 사용하면 API Gateway가 VPC 내부의 AWS 리소스에 액세스할 수 있습니다.

새로운 CDK 스택 파일 생성:

```sh
touch lib/api-gateway-stack.ts
```

다음과 같이 API Gateway 스택을 정의합니다:

```typescript
import * as cdk from 'aws-cdk-lib';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';

interface ApiGatewayStackProps extends cdk.StackProps {
  userPool: cognito.UserPool;
  loadBalancer: elbv2.NetworkLoadBalancer;
}

export class ApiGatewayStack extends cdk.Stack {

  public readonly api: apigateway.RestApi;

  constructor(scope: cdk.App, id: string, props: ApiGatewayStackProps) {
    super(scope, id, props);

    // VPC Link 생성
    const vpcLink = new apigateway.VpcLink(this, 'TodoListVpcLink', {
      targets: [props.loadBalancer]
    });

    // API Gateway 생성
    this.api = new apigateway.RestApi(this, 'TodoListApi', {
      restApiName: 'TodoList Service',
      description: 'TodoList API with authentication'
    });

    // Cognito 권한 부여자 생성
    const authorizer = new apigateway.CognitoUserPoolsAuthorizer(this, 'TodoListAuthorizer', {
      cognitoUserPools: [props.userPool]
    });

    // API 경로 및 메서드 정의는 추후 추가...
  }
}
```

### 배포할 새로운 API Gateway API 정의

우리는 이미 API Gateway Swagger 정의를 `api/api-swagger.json`에 생성해 두었습니다. 이 파일에는 다음이 포함되어 있습니다:

* **GET /todos** - 모든 할일 목록 조회 (인증 불필요)
* **POST /todos** - 새로운 할일 생성 (인증 불필요)
* **POST /todos/{id}/toggle** - 할일 완료 상태 토글 (인증 필요)
* **DELETE /todos/{id}** - 할일 삭제 (인증 필요)

API Gateway 배포를 위해 다음 명령을 실행합니다:

```sh
cd ~/environment/workshop
aws apigateway import-rest-api --body fileb://api/api-swagger.json
```

### 웹사이트 콘텐츠 업데이트

`web/` 디렉토리의 웹사이트 코드를 업데이트하여 새로운 API Gateway 엔드포인트와 Cognito 사용자 풀을 사용하도록 합니다.

1. **index.html** - 메인 TodoList 애플리케이션
2. **register.html** - 사용자 회원가입 페이지  
3. **confirm.html** - 이메일 인증 페이지

각 파일에서 다음 변수들을 실제 값으로 교체해야 합니다:

* `todosApiEndpoint` = 생성된 API Gateway 엔드포인트 URL
* `cognitoUserPoolId` = 생성된 Cognito User Pool ID
* `cognitoUserPoolClientId` = 생성된 Cognito User Pool Client ID
* `awsRegion` = 'ap-northeast-2'

### S3에 웹사이트 업로드

업데이트된 웹사이트 파일들을 S3 버킷에 업로드합니다:

```sh
cd ~/environment/workshop/web
aws s3 cp . s3://REPLACE_ME_BUCKET_NAME --recursive --exclude "*" --include "*.html" --include "*.js" --include "*.css"
```

### 테스트

1. CloudFront 배포 URL을 방문합니다
2. 새로운 사용자로 회원가입을 시도합니다
3. 이메일 인증을 완료합니다
4. 로그인하여 할일 생성, 완료 토글, 삭제 기능을 테스트합니다

### 완료!

축하합니다! 이제 사용자 인증과 권한 부여가 포함된 완전한 TodoList 애플리케이션이 완성되었습니다.

주요 구현 사항:
- AWS Cognito를 통한 사용자 등록 및 인증
- API Gateway를 통한 REST API 엔드포인트 관리
- 인증이 필요한 기능 (할일 완료/삭제)에 대한 접근 제어
- 반응형 웹 UI

다음 모듈에서는 추가적인 기능들을 구현해보겠습니다.


## [AWS Developer Center](https://developer.aws)
