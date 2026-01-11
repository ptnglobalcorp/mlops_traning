# LocalStack: Compute Services Guide

**Hands-on Practice for EC2 and Lambda**

> **Note**: Bash commands in this guide work on Linux, macOS, and Windows (via Git Bash, WSL, or PowerShell with bash support).

## Overview

This guide provides hands-on exercises for AWS Compute Services using LocalStack's FREE tier.

## Services Available in FREE Tier

| Service | Available | Notes |
|---------|-----------|-------|
| **EC2** | ✅ Yes | Full mock implementation |
| **Lambda** | ✅ Yes | Full Python/Node.js runtimes |
| **Elastic Beanstalk** | ❌ No | Requires Base tier |

## Prerequisites

```bash
# Start LocalStack with compute services
docker run --rm -it \
  -p 4566:4566 \
  -e SERVICES=lambda,ec2,iam,sts \
  localstack/localstack

# Or update docker-compose.yml
```

---

## 1. AWS Lambda (Serverless Compute)

### Create a Lambda Function

```bash
# Create project directory
mkdir lambda-demo && cd lambda-demo

# Create handler.py
cat > handler.py << 'EOF'
import json

def lambda_handler(event, context):
    # Log the incoming event
    print("Received event:", json.dumps(event))

    # Extract data from event
    name = event.get('name', 'World')

    # Return response
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Hello, {name}!'
        })
    }
EOF

# Package the function
zip function.zip handler.py

# Create IAM role (required for Lambda)
aws --endpoint-url=http://localhost:4566 iam create-role \
    --role-name lambda-execution-role \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

# Create the Lambda function
aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name hello-world \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/lambda-execution-role \
    --handler handler.lambda_handler \
    --zip-file fileb://function.zip \
    --timeout 10 \
    --memory-size 128

# List functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Get function details
aws --endpoint-url=http://localhost:4566 lambda get-function \
    --function-name hello-world
```

### Invoke Lambda Function

```bash
# Synchronous invocation
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name hello-world \
    --payload '{"name": "LocalStack"}' \
    response.json

# View the response
cat response.json

# Asynchronous invocation
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name hello-world \
    --invocation-type Event \
    --payload '{"name": "Async"}' \
    response.json
```

### Update Lambda Function

```bash
# Update the code
cat > handler.py << 'EOF'
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Updated: Hello from Lambda!',
            'timestamp': str(context.aws_request_id)
        })
    }
EOF

# Re-package
zip -u function.zip handler.py

# Update function code
aws --endpoint-url=http://localhost:4566 lambda update-function-code \
    --function-name hello-world \
    --zip-file fileb://function.zip
```

### Lambda with Environment Variables

```bash
# Update function configuration
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
    --function-name hello-world \
    --environment Variables={TABLE_NAME=Users,REGION=us-east-1}

# Get configuration
aws --endpoint-url=http://localhost:4566 lambda get-function-configuration \
    --function-name hello-world
```

### Delete Lambda Function

```bash
# Delete the function
aws --endpoint-url=http://localhost:4566 lambda delete-function \
    --function-name hello-world
```

---

## 2. Amazon EC2 (Virtual Servers)

### List Available Instance Types

```bash
# Describe instance types (mock data)
aws --endpoint-url=http://localhost:4566 ec2 describe-instance-types \
    --query 'InstanceTypes[?InstanceType==`t2.micro`]'
```

### Create Key Pair

```bash
# Create a key pair
aws --endpoint-url=http://localhost:4566 ec2 create-key-pair \
    --key-name my-key-pair \
    --query 'KeyMaterial' \
    --output text > my-key-pair.pem

# Set permissions
chmod 400 my-key-pair.pem

# List key pairs
aws --endpoint-url=http://localhost:4566 ec2 describe-key-pairs
```

### Create Security Group

```bash
# Create security group
aws --endpoint-url=http://localhost:4566 ec2 create-security-group \
    --group-name my-security-group \
    --description "My security group"

# Add inbound rule (SSH)
aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
    --group-name my-security-group \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Add inbound rule (HTTP)
aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
    --group-name my-security-group \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Describe security groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
    --group-names my-security-group
```

### Launch EC2 Instance

```bash
# Note: In LocalStack, instances are mocked
# This command creates a mock instance record

# Launch instance
INSTANCE_ID=$(aws --endpoint-url=http://localhost:4566 ec2 run-instances \
    --image-id ami-12345678 \
    --count 1 \
    --instance-type t2.micro \
    --key-name my-key-pair \
    --security-groups my-security-group \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# Describe instance
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
    --instance-ids $INSTANCE_ID

# List all instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

### Stop and Terminate Instance

```bash
# Stop instance
aws --endpoint-url=http://localhost:4566 ec2 stop-instances \
    --instance-ids $INSTANCE_ID

# Start instance
aws --endpoint-url=http://localhost:4566 ec2 start-instances \
    --instance-ids $INSTANCE_ID

# Terminate instance
aws --endpoint-url=http://localhost:4566 ec2 terminate-instances \
    --instance-ids $INSTANCE_ID
```

### Working with AMIs

```bash
# Create AMI (mock)
aws --endpoint-url=http://localhost:4566 ec2 create-image \
    --instance-id $INSTANCE_ID \
    --name "my-ami"

# Describe images
aws --endpoint-url=http://localhost:4566 ec2 describe-images
```

---

## 3. Hands-On Projects

### Project 1: REST API with Lambda

```bash
# Create API Gateway
API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-rest-api \
    --name "lambda-api" \
    --query 'id' \
    --output text)

# Create resource
RESOURCE_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_ID \
    --path-part "hello" \
    --query 'id' \
    --output text)

# Create Lambda function
cat > api_handler.py << 'EOF'
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Hello from API Gateway!'})
    }
EOF

zip function.zip api_handler.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name api-handler \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler api_handler.lambda_handler \
    --zip-file fileb://function.zip

# Test the complete flow
echo "API created: $API_ID"
echo "Resource created: $RESOURCE_ID"
```

### Project 2: Lambda with DynamoDB

```bash
# Create DynamoDB table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Visitors \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Create Lambda that writes to DynamoDB
cat > visitors_handler.py << 'EOF'
import json
import boto3
import os

dynamodb = boto3.resource('dynamodb', endpoint_url=os.environ['AWS_ENDPOINT_URL'])
table = dynamodb.Table('Visitors')

def lambda_handler(event, context):
    # Put item
    table.put_item(Item={
        'id': context.aws_request_id,
        'timestamp': str(context.invoked_function_arn)
    })

    # Scan table
    response = table.scan()

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Visit recorded!',
            'total_visitors': response['Count']
        })
    }
EOF

zip function.zip visitors_handler.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name visitor-counter \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler visitors_handler.lambda_handler \
    --zip-file fileb://function.zip \
    --environment Variables={AWS_ENDPOINT_URL=http://localhost:4566}

# Invoke the function
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name visitor-counter \
    response.json

cat response.json
```

### Project 3: Lambda with S3

```bash
# Create S3 bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://lambda-bucket

# Create Lambda that processes S3 events
cat > s3_handler.py << 'EOF'
import json
import boto3

s3 = boto3.client('s3', endpoint_url='http://localhost:4566')

def lambda_handler(event, context):
    # Process S3 event
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get object
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read().decode('utf-8')

        print(f"Processed file: {key}")
        print(f"Content: {content}")

    return {'statusCode': 200}
EOF

zip function.zip s3_handler.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name s3-processor \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler s3_handler.lambda_handler \
    --zip-file fileb://function.zip

# Test with sample event
echo "Test file" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://lambda-bucket/

# Create S3 event notification (if supported)
# Note: Full S3 event support may vary in LocalStack
```

---

## 4. Common Patterns

### Error Handling in Lambda

```python
# error_handler.py
import json

def lambda_handler(event, context):
    try:
        # Your logic here
        result = process_data(event)
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def process_data(event):
    # Your processing logic
    return {'status': 'success'}
```

### Lambda Layers

```bash
# Create a layer
mkdir -p my-layer/python
cd my-layer/python

# Create layer library
cat > utils.py << 'EOF'
def helper_function():
    return "Helper result"
EOF

cd ../
zip -r layer.zip python/

# Publish layer
aws --endpoint-url=http://localhost:4566 lambda publish-layer-version \
    --layer-name my-layer \
    --zip-file fileb://layer.zip \
    --compatible-runtimes python3.9

# List layers
aws --endpoint-url=http://localhost:4566 lambda list-layers
```

### Lambda Aliases and Versions

```bash
# Publish version
aws --endpoint-url=http://localhost:4566 lambda publish-version \
    --function-name hello-world

# Create alias
aws --endpoint-url=http://localhost:4566 lambda create-alias \
    --function-name hello-world \
    --function-version 1 \
    --name PROD

# Update alias
aws --endpoint-url=http://localhost:4566 lambda update-alias \
    --function-name hello-world \
    --function-version 2 \
    --name PROD
```

---

## 5. Practice Exercises

### Exercise 1: Basic Lambda

1. Create a Lambda function that adds two numbers
2. Test with different inputs
3. Verify the output

```python
def lambda_handler(event, context):
    a = event.get('a', 0)
    b = event.get('b', 0)
    return {
        'result': a + b
    }
```

### Exercise 2: Lambda with Environment Variables

1. Create Lambda function that reads environment variables
2. Set DB_HOST, DB_PORT as environment variables
3. Access them in your function

### Exercise 3: EC2 Instance Management

1. Create a security group
2. Launch a mock EC2 instance
3. Stop and start the instance
4. Terminate the instance

### Exercise 4: Error Scenarios

1. Create Lambda with invalid code
2. Test error handling
3. Check CloudWatch Logs (if available)

---

## 6. Cleanup Commands

```bash
# Delete all Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions \
    --query 'Functions[].FunctionName' \
    --output text | xargs -I {} aws --endpoint-url=http://localhost:4566 lambda delete-function --function-name {}

# Terminate all EC2 instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text | xargs -I {} aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids {}

# Delete all security groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
    --query 'SecurityGroups[?GroupName!=`default`].GroupName' \
    --output text | xargs -I {} aws --endpoint-url=http://localhost:4566 ec2 delete-security-group --group-name {}

# Delete all key pairs
aws --endpoint-url=http://localhost:4566 ec2 describe-key-pairs \
    --query 'KeyPairs[].KeyName' \
    --output text | xargs -I {} aws --endpoint-url=http://localhost:4566 ec2 delete-key-pair --key-name {}
```

---

## Additional Resources

### Documentation
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [LocalStack Lambda Guide](https://docs.localstack.cloud/user-guide/aws/lambda/)

### DigitalCloud Cheat Sheets
- [AWS Compute Services Cheat Sheet](https://digitalcloud.training/aws-compute-services/)

### Practice Resources
- [AWS Lambda Examples](https://github.com/awsdocs/aws-lambda-developer-guide/tree/main/sample-apps)
- [LocalStack Samples](https://github.com/localstack/localstack-samples)

---

**Last Updated**: January 2026
