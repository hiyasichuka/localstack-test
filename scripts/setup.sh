#!/bin/bash

# Define variables
LAMBDA_FUNCTION_NAME=localstack-test
APIGW_NAME=localstack-test-apigw
APIGW_RSROUCE_PATH=greeting
APIGW_STAGE=dev

# 1. Create a lambda function

## 1-1. Execute create-function
awslocal lambda create-function \
    --function-name ${LAMBDA_FUNCTION_NAME} \
    --runtime nodejs16.x \
    --handler index.handler \
    --zip-file fileb://function.zip \
    --role dummy

[ $? == 0 ] || exit 1

## 1-2. Get the ARN of the lambda function
LAMBDA_ARN=$(awslocal lambda list-functions --query "Functions[?FunctionName==\`${LAMBDA_FUNCTION_NAME}\`].FunctionArn" --output text)


# 2. Create an API Gateway

## 2-1. Execute create-rest-api
awslocal apigateway create-rest-api --name ${APIGW_NAME}

[ $? == 0 ] || exit 1

## 2-2. Get the REST API ID and the PARENT ID
APIGW_REST_API_ID=$(awslocal apigateway get-rest-apis --query "items[?name==\`${APIGW_NAME}\`].id" --output text)
APIGW_PARENT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${APIGW_REST_API_ID} --query 'items[?path==`/`].id' --output text)


# 3. Create an API Gateway Resource

## 3-1. Execute create-resource
awslocal apigateway create-resource \
    --rest-api-id ${APIGW_REST_API_ID} \
    --parent-id ${APIGW_PARENT_RESOURCE_ID} \
    --path-part ${APIGW_RSROUCE_PATH}

[ $? == 0 ] || exit 1

## 3-2. Get the RESOURCE ID
APIGW_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${APIGW_REST_API_ID} --query "items[?path==\`/${APIGW_RSROUCE_PATH}\`].id" --output text)


# 4. Attach POST endpoint to the resource 
## https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-settings-method-request.html

## 4-1. Execute create-model
awslocal apigateway create-model \
    --rest-api-id ${APIGW_REST_API_ID} \
    --name "greetingMessage" \
    --content-type 'application/json' \
    --schema '{"$schema": "http://json-schema.org/draft-04/schema#", "title": "greetingMessage", "type": "object", "properties": {"message": {"type": "string"}}}'

[ $? == 0 ] || exit 1

## 4-2. Exexute put-method
awslocal apigateway put-method \
    --rest-api-id ${APIGW_REST_API_ID} \
    --resource-id ${APIGW_RESOURCE_ID} \
    --http-method POST \
    --authorization-type "NONE" \
    --request-models '{"application/json": "greetingMessage"}'

[ $? == 0 ] || exit 1


# 5. Integrate the lambda function into the API Gateway
awslocal apigateway put-integration \
    --rest-api-id ${APIGW_REST_API_ID} \
    --resource-id ${APIGW_RESOURCE_ID} \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH \

[ $? == 0 ] || exit 1


# 6. Deploy the endpoint
awslocal apigateway create-deployment \
    --rest-api-id ${APIGW_REST_API_ID} \
    --stage-name ${APIGW_STAGE} \

[ $? == 0 ] || exit 1

# 7. Test
API_ENDPOINT=http://localhost:4566/restapis/${APIGW_REST_API_ID}/${APIGW_STAGE}/_user_request_/${APIGW_RSROUCE_PATH}
echo "ENDPOINT: ${API_ENDPOINT}"

curl -iX POST ${API_ENDPOINT} -H 'Content-Type: application/json' -d '{"message": "Hi"}'
