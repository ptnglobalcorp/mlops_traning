# LocalStack for AWS Service Study

**Local AWS Cloud Development Environment for CLF-C02 Exam Preparation**

## Tool Versions (Pinned for Consistency)

This guide has been tested with the following tool versions. For consistency, we recommend using these versions or newer:

| Tool | Version | Installation Check |
|------|---------|-------------------|
| **Docker** | 28.x+ | `docker --version` |
| **Docker Compose** | v2.24.0+ | `docker compose version` |
| **AWS CLI** | v2.22.0+ | `aws --version` |
| **LocalStack** | 4.12.0+ | `docker run localstack/localstack:latest` |
| **Python** | 3.9+ (optional) | `python --version` |

### Installation Links

- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
- **Docker Engine**: https://docs.docker.com/engine/install/
- **AWS CLI**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- **Python**: https://www.python.org/downloads/

## Overview

**LocalStack** is a fully functional local AWS cloud stack that enables you to develop and test your cloud and serverless applications without connecting to AWS. It provides an emulated environment for AWS services that runs in a Docker container on your local machine.

### Why Use LocalStack for AWS Study?

- **Zero AWS Costs**: No charges for testing and learning
- **Fast Development**: No network latency, instant responses
- **Offline Development**: Work without internet connection
- **Safe Testing**: Experiment freely without affecting production AWS resources
- **CI/CD Integration**: Perfect for automated testing pipelines
- **Reproducible Environments**: Consistent local setup across team members

## LocalStack Tiers (2025)

As of May 8, 2025, LocalStack is offered in four tiers:

| Tier | Cost | Best For | CI Credits |
|------|------|----------|------------|
| **Free** | $0 | Learning, development, personal projects | None |
| **Base** | $39/month | Professional development, small teams | 300 credits/month |
| **Ultimate** | Custom | Production development, enterprise features | 1000 credits/month |
| **Enterprise** | Contact Sales | Large organizations, custom needs | Unlimited |

**This guide focuses on the FREE tier and which AWS services are available for study.**

## Installation

### Prerequisites

- Docker Desktop or Docker Engine
- 4GB RAM minimum (8GB recommended)
- Python 3.7+ (for LocalStack CLI)
- AWS CLI (optional, for testing)

### Installation Methods

#### Method 1: Docker CLI (Recommended)

```bash
# Pull the latest LocalStack image
docker pull localstack/localstack:latest

# Start LocalStack
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

#### Method 2: Docker Compose (Recommended with .env configuration)

**Quick Start with provided files**:

```bash
cd module-01/aws/localstack
cp .env.example .env
docker compose up -d
```

**Windows PowerShell**:
```powershell
cd module-01\aws\localstack
copy .env.example .env
docker compose up -d
```

**Features**:
- Docker volume for data persistence (Pro feature - see notes below)
- Environment variable configuration via `.env` file
- Resource limits and health checks pre-configured
- Cross-platform compatible

**Important Notes**:
- **Persistence is Pro-only**: Community Edition is ephemeral by design. State is not persisted across container restarts.
- **Services load on-demand**: In LocalStack 4.x, services are loaded automatically when accessed - no need to specify them.

**Or create your own `docker-compose.yml`**:

```yaml
volumes:
  localstack-data:
    driver: local

services:
  localstack:
    image: localstack/localstack:4.12.0
    container_name: localstack-main
    ports:
      - "127.0.0.1:4566:4566"
      - "127.0.0.1:4510-4559:4510-4559"
    environment:
      # Core configuration
      - DEBUG=0
      # Persistence (Pro-only feature - Community Edition is ephemeral)
      - PERSISTENCE=1
    volumes:
      - localstack-data:/var/lib/localstack
      - /var/run/docker.sock:/var/run/docker.sock
```

Start with:

```bash
docker compose up
```

Stop and remove data:

```bash
docker compose down -v  # -v removes associated volumes
```

> **Notes**:
> - The `version` field in docker-compose.yml is deprecated and no longer required in Docker Compose v2+
> - `SERVICES` variable is deprecated in 4.x - services load on-demand automatically
> - `DATA_DIR` variable is deprecated in 4.x - state is stored in `/var/lib/localstack`
> - Volume mount must be to `/var/lib/localstack` for persistence to work (Pro-only)
> - On Windows with Docker Desktop, the Docker socket is usually handled automatically
> - Use `docker volume ls` to list all volumes and `docker volume inspect localstack-data` to view volume details
> - **Community Edition is ephemeral** - data is not persisted across container restarts (persistence is Pro-only)

#### Method 3: Python pip

```bash
pip install localstack

# Start LocalStack
localstack start
```

### Verifying Installation

```bash
# Check if LocalStack is running
curl http://localhost:4566/_localstack/health

# Expected response:
# {"status": "ok"}
```

## Configuring AWS CLI for LocalStack

LocalStack requires AWS credentials to be configured. Use test credentials for local development:

```bash
# Option 1: Create a dedicated LocalStack profile (recommended)
aws configure set aws_access_key_id test --profile localstack
aws configure set aws_secret_access_key test --profile localstack
aws configure set region us-east-1 --profile localstack

# Verify configuration
aws --profile localstack configure list

# Option 2: Set environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1

# Set the endpoint URL for all commands
export AWS_ENDPOINT_URL=http://localhost:4566

# Or use in each command:
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls
```

**Important**: For S3 pre-signed URLs to work correctly, credentials must be set to `test`/`test`.

## Service Coverage - FREE Tier

### Services Available in FREE Tier

The following AWS services covered in the CLF-C02 exam are available in the LocalStack **FREE tier**:

#### Compute Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **EC2** | ✅ Yes | Full mock implementation |
| **Lambda** | ✅ Yes | Full support with Docker/Lambda execution |
| **Elastic Beanstalk** | ❌ No | Requires Base tier |

#### Storage Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **S3** | ✅ Yes | Full S3 API support including versioning |
| **S3 Control** | ✅ Yes | S3 control plane operations |
| **EBS** | ✅ Yes | Included with EC2 mock |
| **EFS** | ❌ No | Requires Base tier |
| **S3 Glacier** | ❌ No | Requires Base tier |

#### Database Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **DynamoDB** | ✅ Yes | Full DynamoDB support |
| **DynamoDB Streams** | ✅ Yes | Streams functionality included |
| **RDS** | ❌ No | Requires Base tier |
| **ElastiCache** | ❌ No | Requires Base tier |
| **Aurora** | ❌ No | Part of RDS (Base tier) |

#### Networking Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **Route 53** | ✅ Yes | DNS mock implementation |
| **API Gateway (REST)** | ✅ Yes | Full REST API support |
| **API Gateway (HTTP)** | ❌ No | Requires Base tier |
| **CloudFront** | ❌ No | Requires Base tier |
| **VPC** | ✅ Yes | VPC and networking mock |
| **ELB/ELBv2** | ❌ No | Requires Base tier |
| **Direct Connect** | N/A | Not applicable for local |

#### Analytics Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **Kinesis Data Streams** | ✅ Yes | Full Kinesis streams support |
| **Kinesis Data Firehose** | ✅ Yes | Firehose delivery supported |
| **Kinesis Data Analytics** | ❌ No | Requires Base tier |
| **Athena** | ❌ No | Requires Ultimate tier |
| **Redshift** | ✅ Yes | Redshift mock available |
| **EMR** | ❌ No | Requires Ultimate tier |
| **Glue** | ❌ No | Requires Ultimate tier |
| **OpenSearch/Elasticsearch** | ✅ Yes | Full search service support |
| **QuickSight** | ❌ No | Not available in LocalStack |
| **MSK** | ❌ No | Requires Base tier |

#### Security & Compliance Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **IAM** | ✅ Yes | Full IAM policy enforcement |
| **KMS** | ✅ Yes | Key management mock |
| **Secrets Manager** | ✅ Yes | Secrets storage supported |
| **Certificate Manager** | ✅ Yes | SSL certificate mock |
| **STS** | ✅ Yes | Security Token Service |
| **Cognito** | ❌ No | Requires Base tier |
| **WAF** | ❌ No | Requires Base tier |
| **Shield** | ❌ No | Requires Base tier |
| **GuardDuty** | N/A | Not available in LocalStack |

#### Application Integration Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **SNS** | ✅ Yes | Full SNS topic/subscription support |
| **SQS** | ✅ Yes | Full SQS queue support |
| **Step Functions** | ✅ Yes | Workflow orchestration |
| **EventBridge** | ✅ Yes | Event bus and rules |

#### Management & Governance Services

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **CloudFormation** | ✅ Yes | Full CloudFormation support |
| **CloudWatch Metrics** | ✅ Yes | Metrics storage and retrieval |
| **CloudWatch Logs** | ✅ Yes | Log storage and queries |
| **CloudTrail** | ❌ No | Requires Ultimate tier |
| **Config** | ✅ Yes | Configuration tracking |
| **Systems Manager** | ✅ Yes | Parameter Store supported |
| **Resource Groups** | ✅ Yes | Resource organization |
| **Support API** | ✅ Yes | AWS Support mock |

### Services NOT Available (Limitations)

The following CLF-C02 services are **NOT available** in LocalStack Free tier:

| Service | Reason |
|---------|--------|
| **Elastic Beanstalk** | Requires Base tier |
| **EFS** | Requires Base tier |
| **S3 Glacier** | Requires Base tier |
| **RDS** | Requires Base tier |
| **ElastiCache** | Requires Base tier |
| **Aurora** | Part of RDS (Base tier) |
| **API Gateway HTTP/WebSocket** | Requires Base tier |
| **CloudFront** | Requires Base tier |
| **ELB/ELBv2** | Requires Base tier |
| **Kinesis Data Analytics** | Requires Base tier |
| **Athena** | Requires Ultimate tier |
| **EMR** | Requires Ultimate tier |
| **Glue** | Requires Ultimate tier |
| **MSK** | Requires Base tier |
| **Cognito** | Requires Base tier |
| **WAF** | Requires Base tier |
| **Shield** | Requires Base tier |
| **CloudTrail** | Requires Ultimate tier |
| **QuickSight** | Not available (BI service) |

## Getting Started with LocalStack

### 1. Test S3 (Storage)

```bash
# Create a bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket

# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Upload a file
echo "Hello LocalStack" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://my-test-bucket/

# List objects
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-test-bucket

# Download the file
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-test-bucket/test.txt test-downloaded.txt
```

### 2. Test Lambda (Compute)

```bash
# Create a simple Lambda function
mkdir lambda-test
cd lambda-test

# Create handler.py
cat > handler.py << 'EOF'
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from LocalStack Lambda!'
        })
    }
EOF

# Create the Lambda function
aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name my-test-function \
    --runtime python3.11 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler handler.lambda_handler \
    --zip-file fileb://function.zip \
    --timeout 10

# Zip the function
zip -r function.zip handler.py

# Invoke the Lambda
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name my-test-function \
    response.json

# View the response
cat response.json
```

### 3. Test DynamoDB (Database)

```bash
# Create a table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Users \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
        AttributeName=Username,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
        AttributeName=Username,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# List tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Put an item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Users \
    --item '{"UserId":{"S":"user1"},"Username":{"S":"john_doe"},"Email":{"S":"john@example.com"}}'

# Get the item
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name Users \
    --key '{"UserId":{"S":"user1"},"Username":{"S":"john_doe"}}'

# Scan the table
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name Users
```

### 4. Test Kinesis (Analytics)

```bash
# Create a Kinesis stream
aws --endpoint-url=http://localhost:4566 kinesis create-stream \
    --stream-name my-test-stream \
    --shard-count 1

# List streams
aws --endpoint-url=http://localhost:4566 kinesis list-streams

# Describe the stream
aws --endpoint-url=http://localhost:4566 kinesis describe-stream \
    --stream-name my-test-stream

# Put a record
aws --endpoint-url=http://localhost:4566 kinesis put-record \
    --stream-name my-test-stream \
    --partition-key test-key \
    --data "SGVsbG8gTG9jYWxTdGFjayE="

# Get records (using shard iterator)
SHARD_ITERATOR=$(aws --endpoint-url=http://localhost:4566 kinesis get-shard-iterator \
    --stream-name my-test-stream \
    --shard-id shardId-000000000000 \
    --shard-iterator-type TRIM_HORIZON \
    --query 'ShardIterator' \
    --output text)

aws --endpoint-url=http://localhost:4566 kinesis get-records \
    --shard-iterator $SHARD_ITERATOR
```

### 5. Test SQS (Application Integration)

```bash
# Create a queue
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name my-test-queue

# List queues
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Send a message
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name my-test-queue --query 'QueueUrl' --output text)

aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url $QUEUE_URL \
    --message "Hello from SQS in LocalStack!"

# Receive messages
aws --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url $QUEUE_URL
```

### 6. Test CloudFormation (Infrastructure as Code)

```bash
# Create a CloudFormation template
cat > template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'LocalStack Test S3 Bucket'

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-cloudformation-bucket

Outputs:
  BucketName:
    Description: 'Name of the S3 bucket'
    Value: !Ref MyBucket
EOF

# Create the stack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
    --stack-name my-test-stack \
    --template-body file://template.yaml

# Describe the stack
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
    --stack-name my-test-stack

# List stacks
aws --endpoint-url=http://localhost:4566 cloudformation list-stacks
```

## LocalStack CLI Commands

### Starting and Stopping

```bash
# Start LocalStack
localstack start

# Stop LocalStack
localstack stop

# Check status
localstack status

# Start with specific services
SERVICES=s3,dynamodb,lambda localstack start
```

### Docker Commands

```bash
# Start with specific configuration
docker run --rm -it \
  -p 4566:4566 \
  -p 4510-4559:4510-4559 \
  -e SERVICES=lambda,s3,dynamodb,kinesis \
  -e DEBUG=1 \
  -e DATA_DIR=/tmp/localstack/data \
  -v "$(pwd)/volume:/tmp/localstack/data" \
  localstack/localstack

# View logs
docker logs -f localstack_main

# Stop container
docker stop localstack_main

# Remove container
docker rm localstack_main
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SERVICES` | Comma-separated list of services | All services |
| `DEBUG` | Enable debug output | `0` |
| `DATA_DIR` | Directory for persistent data | `/tmp/localstack/data` |
| `PORT_WEB_UI` | Port for web UI | `8080` |
| `LAMBDA_EXECUTOR` | Lambda execution mode | `docker` |
| `KINESIS_ERROR_PROBABILITY` | Kinesis failure injection | `0.0` |

### Configuration File

Create `localstack-config.yaml`:

```yaml
services:
  - s3
  - lambda
  - dynamodb
  - kinesis
  - apigateway
  - iam
  - sns
  - sqs
  - logs

debug: true
data_dir: /tmp/localstack/data

lambda:
  executor: docker
  docker_network: localstack_local

kinesis:
  error_probability: 0.0

web_ui:
  port: 8080
```

Start with config:

```bash
docker run --rm -it \
  -v $(pwd)/localstack-config.yaml:/etc/localstack-config.yaml \
  -p 4566:4566 \
  localstack/localstack
```

## Web UI

LocalStack includes a web UI for monitoring and debugging:

```bash
# Access the web UI
open http://localhost:8080
# Or in browser: http://localhost:8080
```

Features:
- Resource viewer
- Service status dashboard
- Request/response logs
- CloudFormation stack visualization
- Lambda function logs

## Best Practices for Study

### 1. Service-Specific Practice

**S3 Practice**:
- Create buckets with different storage classes
- Upload, download, and delete objects
- Test versioning and lifecycle policies
- Practice bucket policies

**Lambda Practice**:
- Create functions with different runtimes
- Test environment variables
- Practice Lambda layers
- Test Lambda with S3, DynamoDB triggers

**DynamoDB Practice**:
- Create tables with different schemas
- Test CRUD operations
- Practice with indexes (GSI, LSI)
- Test DynamoDB Streams

**Kinesis Practice**:
- Create and manage streams
- Test shard operations
- Practice with Kinesis Firehose

### 2. CloudFormation Practice

Use CloudFormation to practice infrastructure as code:

```yaml
# Complete S3 + Lambda + DynamoDB stack
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Serverless API in LocalStack'

Resources:
  # S3 Bucket for storage
  DataBucket:
    Type: AWS::S3::Bucket

  # DynamoDB Table
  UsersTable:
    Type: AWS::DynamoDB::Table
    Properties:
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      BillingMode: PAY_PER_REQUEST

  # Lambda Function
  ProcessorFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.11
      Handler: index.handler
      Code:
        ZipFile: |
          def handler(event, context):
            return {'statusCode': 200, 'body': 'Hello!'}
      Role: !GetAtt LambdaRole.Arn

  # IAM Role
  LambdaRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
```

### 3. Testing Commands

Create a test script `test-localstack.sh`:

```bash
#!/bin/bash

ENDPOINT=http://localhost:4566

echo "Testing LocalStack..."
echo

# Test S3
echo "1. Testing S3..."
aws --endpoint-url=$ENDPOINT s3 mb s3://test-bucket
aws --endpoint-url=$ENDPOINT s3 ls
echo

# Test DynamoDB
echo "2. Testing DynamoDB..."
aws --endpoint-url=$ENDPOINT dynamodb create-table \
    --table-name TestTable \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
echo

# Test Lambda
echo "3. Testing Lambda..."
# Add Lambda test commands here
echo

echo "All tests completed!"
```

## Troubleshooting

### Common Issues

**Port Already in Use**:

*Linux/macOS*:
```bash
# Find and kill process using port 4566
lsof -ti:4566 | xargs kill -9

# Or use different port
docker run --rm -it -p 4567:4566 localstack/localstack
```

*Windows PowerShell*:
```powershell
# Find process using port 4566
Get-NetTCPConnection -LocalPort 4566 | Select-Object -Property State, OwningProcess
# Kill the process using the PID
Stop-Process -Id <PID> -Force
```

*Windows Command Prompt*:
```cmd
# Find process using port 4566
netstat -ano | findstr :4566
# Kill the process using the PID
taskkill /PID <PID> /F
```

**Container Not Starting**:
```bash
# Check Docker is running
docker ps

# Check container logs
docker logs localstack_main

# Restart Docker Desktop (if using Mac/Windows)
```

**Services Not Responding**:
```bash
# Check health endpoint
curl http://localhost:4566/_localstack/health

# Enable debug mode
docker run --rm -it -e DEBUG=1 -p 4566:4566 localstack/localstack
```

**Lambda Execution Failures**:
```bash
# Ensure Docker is available for Lambda
docker ps

# Check Lambda logs
docker logs localstack_main | grep lambda
```

## Study Tips

### 1. Progressive Learning Path

1. **Week 1**: S3, DynamoDB, Lambda (Core services)
2. **Week 2**: Kinesis, SQS, SNS (Messaging)
3. **Week 3**: API Gateway, CloudFormation (Integration)
4. **Week 4**: IAM, KMS, CloudWatch (Security & Monitoring)

### 2. Hands-On Exercises

For each service:
1. Read the AWS documentation
2. Practice basic operations in LocalStack
3. Build a simple use case
4. Test error scenarios
5. Practice with AWS CLI commands

### 3. Practice Scenarios

**Scenario 1: Serverless API**
- Create API Gateway
- Add Lambda backend
- Store data in DynamoDB
- Test the complete flow

**Scenario 2: Data Pipeline**
- Create S3 bucket
- Create Kinesis stream
- Create Lambda processor
- Store results in DynamoDB

**Scenario 3: Microservices**
- Create SQS queues
- Create Lambda consumers
- Implement SNS notifications
- Test message flow

## Limitations of FREE Tier

### Service Limitations

The following CLF-C02 exam topics **cannot be practiced** with LocalStack FREE tier:

| Topic | Services Affected |
|-------|-------------------|
| **Elastic Beanstalk** | PaaS deployment |
| **EFS** | Network file storage |
| **RDS/Aurora** | Relational databases |
| **ElastiCache** | In-memory caching |
| **CloudFront** | CDN |
| **ELB/ELBv2** | Load balancing |
| **Athena** | Serverless queries |
| **EMR/Glue** | Big data processing |
| **QuickSight** | BI dashboards |

### Alternative Learning Strategies

For services NOT in LocalStack FREE tier:
1. **Use AWS Free Tier** for RDS, CloudFront, ELB
2. **Read Documentation** for conceptual understanding
3. **Watch Video Tutorials** for service demonstrations
4. **Use DigitalCloud Cheat Sheets** for exam prep
5. **Practice with AWS Console** (sandbox accounts available)

## Additional Resources

### Official Documentation
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [Docker Installation](https://docs.docker.com/get-docker/)

### LocalStack Resources
- [LocalStack Blog](https://localstack.cloud/blog/)
- [LocalStack Community](https://localstack.cloud/community/)
- [LocalStack YouTube Channel](https://www.youtube.com/c/localstack)
- [LocalStack Stack Overflow](https://stackoverflow.com/questions/tagged/localstack)

### Learning Resources
- [AWS CLI Cheat Sheet](https://digitalcloud.training/)
- [LocalStack Recipes](https://github.com/localstack/localstack-recipes)
- [Sample Projects](https://github.com/localstack/sample-integration-tests)

### Pricing and Tiers
- [LocalStack Pricing](https://localstack.cloud/pricing/)
- [LocalStack Licensing](https://docs.localstack.cloud/aws/licensing/)
- [Feature Comparison](https://localstack.cloud/features/)

---

**Last Updated**: January 2025 | **LocalStack Version**: 4.12.0 (Community Edition)
