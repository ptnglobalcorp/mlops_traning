# LocalStack Lab

**Practice AWS services locally without cost**

This lab uses [LocalStack 4.12](https://docs.localstack.cloud/) - a fully functional local AWS cloud stack for development and testing. LocalStack allows you to run AWS services locally on your machine, enabling you to build and test cloud applications without incurring AWS costs.

## Quick Start

### Prerequisites

- Docker Desktop installed and running
- AWS CLI v2 installed
- Basic familiarity with AWS services

### Setup

```bash
# Navigate to this directory
cd module-01/aws

# Copy environment configuration
cp .env.example .env

# Start LocalStack
docker compose up -d

# View logs (optional)
docker compose logs -f localstack

# Check health status
curl http://localhost:4566/_localstack/health
```

### Configure AWS CLI

LocalStack requires AWS credentials to be configured. Use test credentials for local development:

```bash
# Option 1: Create a dedicated LocalStack profile (recommended)
aws configure set aws_access_key_id test --profile localstack
aws configure set aws_secret_access_key test --profile localstack
aws configure set region us-east-1 --profile localstack

# Option 2: Set environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1
```

**Important:** For S3 pre-signed URLs to work correctly, credentials must be set to `test`/`test`.

## Lab Exercises

### Exercise 1: S3 Bucket Operations

```bash
# List buckets
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls

# Create a bucket
aws --profile localstack --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket --region us-east-1

# Create a test file
echo "Hello LocalStack!" > test.txt

# Upload a file
aws --profile localstack --endpoint-url=http://localhost:4566 s3 cp test.txt s3://my-test-bucket/

# List bucket contents
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls s3://my-test-bucket

# Download a file
aws --profile localstack --endpoint-url=http://localhost:4566 s3 cp s3://my-test-bucket/test.txt downloaded.txt

# Delete objects and bucket
aws --profile localstack --endpoint-url=http://localhost:4566 s3 rm s3://my-test-bucket/test.txt
aws --profile localstack --endpoint-url=http://localhost:4566 s3 rb s3://my-test-bucket --region us-east-1
```

### Exercise 2: DynamoDB Table Operations

```bash
# Create table
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=UserId,AttributeType=S \
    --key-schema AttributeName=UserId,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# List tables
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb list-tables

# Put item
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Users \
    --item '{"UserId": {"S": "user1"}, "Name": {"S": "Alice"}, "Email": {"S": "alice@example.com"}}'

# Get item
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name Users \
    --key '{"UserId": {"S": "user1"}}'

# Scan table
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb scan \
    --table-name Users

# Delete table
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb delete-table \
    --table-name Users
```

### Exercise 3: Lambda Function

```bash
# Create handler directory
mkdir lambda && cd lambda

# Create Lambda handler
cat > handler.py << 'EOF'
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Hello from LocalStack!'})
    }
EOF

# Package the function
zip function.zip handler.py

# Create IAM role (using test role ARN for LocalStack)
aws --profile localstack --endpoint-url=http://localhost:4566 iam create-role \
    --role-name test-lambda-role \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

# Create function
aws --profile localstack --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name my-function \
    --runtime python3.11 \
    --role arn:aws:iam::000000000000:role/test-lambda-role \
    --handler handler.lambda_handler \
    --zip-file fileb://function.zip

# Wait for function to be ready
aws --profile localstack --endpoint-url=http://localhost:4566 lambda wait function-active-v2 \
    --function-name my-function

# Invoke function
aws --profile localstack --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name my-function \
    response.json

cat response.json

# List functions
aws --profile localstack --endpoint-url=http://localhost:4566 lambda list-functions

# Delete function
aws --profile localstack --endpoint-url=http://localhost:4566 lambda delete-function \
    --function-name my-function
```

### Exercise 4: SQS Queue Operations

```bash
# Create queue
aws --profile localstack --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name my-test-queue

# List queues
aws --profile localstack --endpoint-url=http://localhost:4566 sqs list-queues

# Send message
aws --profile localstack --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/my-test-queue \
    --message-body "Hello SQS!"

# Receive message
aws --profile localstack --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url http://localhost:4566/000000000000/my-test-queue

# Delete queue
aws --profile localstack --endpoint-url=http://localhost:4566 sqs delete-queue \
    --queue-url http://localhost:4566/000000000000/my-test-queue
```

### Exercise 5: SNS Topic Operations

```bash
# Create topic
aws --profile localstack --endpoint-url=http://localhost:4566 sns create-topic \
    --name my-test-topic

# List topics
aws --profile localstack --endpoint-url=http://localhost:4566 sns list-topics

# Subscribe to topic (email example)
aws --profile localstack --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-test-topic \
    --protocol email \
    --notification-endpoint test@example.com

# Publish message
aws --profile localstack --endpoint-url=http://localhost:4566 sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-test-topic \
    --message "Hello SNS!"

# Delete topic
aws --profile localstack --endpoint-url=http://localhost:4566 sns delete-topic \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-test-topic
```

## Configuration

### Environment Variables (.env)

| Variable | Default | Description |
|----------|---------|-------------|
| `LOCALSTACK_CONTAINER_NAME` | `localstack-main` | Container name |
| `LOCALSTACK_IMAGE` | `localstack/localstack:4.12.0` | Docker image |
| `PERSISTENCE` | `1` | Enable data persistence |
| `DEBUG` | `0` | Enable debug logging |
| `DNS_ADDRESS` | `0` | DNS server address (0 = disabled) |

### Docker Compose Structure

| Component | Purpose |
|-----------|---------|
| `docker-compose.yml` | Container orchestration |
| `.env` | Environment variables |
| `localstack-data` volume | Persistent data storage |

### Data Persistence

LocalStack data is persisted in a Docker volume named `localstack-data`. To manage the volume:

```bash
# List volumes
docker volume ls | grep localstack

# Inspect volume
docker volume inspect localstack-data

# Remove volume (after stopping container)
docker volume rm localstack-data
```

## LocalStack Web Application

LocalStack provides a web application to view and manage your local resources:

- **URL**: https://app.localstack.cloud/
- **Status Page**: View deployed resources, logs, and metrics
- **Resource Browser**: Inspect S3 buckets, Lambda functions, DynamoDB tables, etc.

To access the web application for your local instance, navigate to the **Default Instance** after starting LocalStack.

## Cleanup

```bash
# Stop LocalStack
docker compose down

# Stop LocalStack and remove volumes
docker compose down -v

# Remove the data volume
docker volume rm localstack-data

# Remove Lambda artifacts
rm -rf lambda/
```

## Troubleshooting

### Port already in use

```bash
# Find process on port 4566 (Windows)
netstat -ano | findstr :4566

# Kill the process
taskkill /PID <PID> /F
```

### Container not starting

```bash
# Check Docker is running
docker ps

# View logs
docker compose logs localstack

# Check container status
docker ps -a | grep localstack
```

### AWS CLI authentication errors

```bash
# Verify credentials are configured
aws --profile localstack configure list

# Verify endpoint is reachable
curl http://localhost:4566/_localstack/health

# Test with explicit credentials
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url=http://localhost:4566 s3 ls
```

### Services showing as "disabled"

In LocalStack 4.x, services load **on-demand** by default. This is expected behavior - services will activate automatically when you make API calls to them.

## Available Services

LocalStack Community Edition (free) supports 37+ AWS services including:

| Service Category | Services |
|------------------|----------|
| **Storage** | S3, EFS |
| **Compute** | Lambda, EC2, ECS, EKS, Batch |
| **Database** | DynamoDB, ElastiCache, RDS, DocumentDB, Neptune, Redshift |
| **Messaging** | SQS, SNS, Kinesis |
| **API Management** | API Gateway, REST APIs |
| **Identity** | IAM, STS, Cognito |
| **Management** | CloudFormation, CloudWatch, Step Functions, Secrets Manager, SSM |
| **Analytics** | Firehose, Glue, Athena, OpenSearch, Redshift |
| **Network** | VPC, Route 53, CloudFront |

For a complete list and API coverage, see:
- [LocalStack Supported Services](https://docs.localstack.cloud/aws/supported-services/)
- [LocalStack API Coverage](https://docs.localstack.cloud/aws/api-coverage/)

## Study Path

1. **Read AWS service guides** in [`docs/module-01/aws/`](../../docs/module-01/aws/)
2. **Practice with exercises** in this directory
3. **Explore LocalStack features**:
   - [LocalStack Documentation](https://docs.localstack.cloud/)
   - [LocalStack Web Application](https://app.localstack.cloud/)
4. **Combine with infrastructure-as-code**:
   - Terraform lab in [`module-01/terraform/basics/`](../terraform/)
   - Serverless Framework
   - AWS CDK

## Additional Resources

### Official Documentation
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack Quick Start](https://docs.localstack.cloud/aws/getting-started/quickstart/)
- [LocalStack Installation](https://docs.localstack.cloud/aws/getting-started/installation/)
- [Configuration Reference](https://docs.localstack.cloud/references/configuration/)

### Learning Resources
- [LocalStack Blog](https://blog.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)
- [LocalStack Discord](https://discord.localstack.cloud/)

### Tools & Integrations
- [`awslocal` CLI wrapper](https://github.com/localstack/awscli-local)
- [Terraform LocalStack Provider](https://registry.terraform.io/providers/localstack/localstack/latest/docs)
- [Serverless Framework Plugin](https://www.serverless.com/plugins/serverless-localstack)

## Version Information

- **LocalStack Version**: 4.12.0
- **AWS CLI**: v2 (recommended)
- **Docker Compose**: v2.0+
- **Python Lambda Runtime**: 3.11 (latest stable)

---

**Note**: This lab environment is for local development and testing only. Always test thoroughly before deploying to production AWS environments.
