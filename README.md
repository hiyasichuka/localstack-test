# localstack-test

## Prepare

Install awscli provided by AWS.
For more details, please refer to <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html>.

```sh
brew insatll awscli
```

Install awscli-local provided by LocalStack. This is optional but strongly recommended.
For more details, please refer to <https://github.com/localstack/awscli-local>.

```sh
pip install awscli-local
```

## How to use

Start LocalStack server using `docker-compose`.

```sh
docker-compose up
```

Run the setup script.

```sh
npm run apigateway:setup
```

Call the API via API Gateway without payload.

```sh
curl -iX POST http://localhost:4566/restapis/8vcjr5pkdq/dev/_user_request_/greeting
```

```sh
HTTP/1.1 200 
content-type: application/json
Content-Length: 27
Connection: close
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: HEAD,GET,PUT,POST,DELETE,OPTIONS,PATCH
Access-Control-Allow-Headers: authorization,cache-control,content-length,content-md5,content-type,etag,location,x-amz-acl,x-amz-content-sha256,x-amz-date,x-amz-request-id,x-amz-security-token,x-amz-tagging,x-amz-target,x-amz-user-agent,x-amz-version-id,x-amzn-requestid,x-localstack-target,amz-sdk-invocation-id,amz-sdk-request
Access-Control-Expose-Headers: etag,x-amz-version-id
date: Wed, 28 Sep 2022 06:21:51 GMT
server: hypercorn-h11

{"message":"Hello, World!"}
```

Call the API via API Gateway with payload.

```sh
curl -iX POST http://localhost:4566/restapis/8vcjr5pkdq/dev/_user_request_/greeting -H 'content-type: application/json' -d '{"message": "Hi"}'
```

```sh
HTTP/1.1 200 
content-type: application/json
Content-Length: 24
Connection: close
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: HEAD,GET,PUT,POST,DELETE,OPTIONS,PATCH
Access-Control-Allow-Headers: authorization,cache-control,content-length,content-md5,content-type,etag,location,x-amz-acl,x-amz-content-sha256,x-amz-date,x-amz-request-id,x-amz-security-token,x-amz-tagging,x-amz-target,x-amz-user-agent,x-amz-version-id,x-amzn-requestid,x-localstack-target,amz-sdk-invocation-id,amz-sdk-request
Access-Control-Expose-Headers: etag,x-amz-version-id
date: Wed, 28 Sep 2022 06:21:37 GMT
server: hypercorn-h11

{"message":"Hi, World!"}
```

Invoke lambda using AWS CLI.

```sh
npm run lambda:invoke
```

Show the Lambda function log.

```sh
npm run lambda:logs
```

Stop the LocalStack server.

```sh
docker-compose down -v
```


## Resoruces

### Building Lambda functions with TypeScript

<https://docs.aws.amazon.com/lambda/latest/dg/lambda-typescript.html>

```ts
import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda'

export const lambdaHandler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`)
  console.log(`Context: ${JSON.stringify(context, null, 2)}`)
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'hello world'
    })
  }
}
```

### A collection of .gitignore templates

Download `.gitignore` for Node.js.

```sh
curl https://raw.githubusercontent.com/github/gitignore/main/Node.gitignore -o Node.gitignore
```

Download `.gitignore` for macOS.

```sh
curl https://raw.githubusercontent.com/github/gitignore/main/Global/macOS.gitignore -o macOS.gitignore
```

Merge to one `.gitignore` file.

```sh
cat *.gitignore > .gitignore && rm *.gitignore
```

You shoud ignore following path manually.

```sh
# Lambda .zip file archives
function.zip

# Lambda response file
response.json
```