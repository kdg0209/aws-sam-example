#!/bin/bash

set -e  # 에러 발생 시 스크립트 중단

sam build
sam sam validate

# 변수 지정
bucket_name="aws-node-lambda-library"
region="ap-northeast-2"
profile="sam"
layer_file="nodejs.zip"
functionDir="HelloWorldFunction"

# node_modules 삭제
rm -rf .aws-sam/build/$functionDir/node_modules

# nodejs 디렉토리 생성 후 라이브러리 이동 및 zip 파일 생성
mkdir nodejs
mv ./hello-world/node_modules nodejs
zip -r $layer_file ./nodejs

# S3 버킷 존재 여부 확인 후 생성
if ! aws s3 ls "s3://$bucket_name" --region $region --profile $profile > /dev/null 2>&1; then
  echo "Bucket does not exist. Creating bucket: $bucket_name"
  aws s3 mb s3://$bucket_name --region $region --profile $profile
else
  echo "✅ Bucket $bucket_name already exists. Skipping creation."
fi

# 압축 파일을 S3 버킷에 업로드
aws s3 cp $layer_file s3://$bucket_name/$layer_file --profile $profile
echo "✅ Uploaded $layer_file to S3"

# 최신 Layer ARN 가져오기
latest_layer_arn=$(aws lambda publish-layer-version \
  --layer-name "NodeJsDependencies" \
  --content S3Bucket=$bucket_name,S3Key=$layer_file \
  --compatible-runtimes "nodejs22.x" \
  --region $region --profile $profile \
  --query 'LayerVersionArn' --output text)

echo "🚀 Latest Layer ARN: $latest_layer_arn"

# SAM Deploy 실행 (LayerArn 값을 전달)
sam deploy --parameter-overrides LayerArn=$latest_layer_arn --guided --profile $profile

# 압축 파일 삭제 및 디렉토리 삭제
rm -rf $layer_file
rm -rf nodejs
rm -rf ./aws-sam

echo "🎉 Deploy completed"