# LocalStack Quick Start Guide

**Get Started with LocalStack for AWS Service Practice in 5 Minutes**

## Tool Versions (Pinned for Consistency)

This guide has been tested with the following tool versions. For consistency, we recommend using these versions or newer:

| Tool | Version | Installation Check |
|------|---------|-------------------|
| **Docker** | 28.x+ | `docker --version` |
| **Docker Compose** | v2.24.0+ | `docker compose version` |
| **AWS CLI** | v2.22.0+ | `aws --version` |
| **LocalStack** | 4.0.0+ | `docker run localstack/localstack:latest` |
| **Python** | 3.9+ (optional) | `python --version` |

### Installation Links

- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
- **Docker Engine**: https://docs.docker.com/engine/install/
- **AWS CLI**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- **Python**: https://www.python.org/downloads/

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check Docker is installed
docker --version

# Check Docker is running
docker ps

# Check AWS CLI is installed
aws --version

# Check Python (optional)
python --version
```

## Installation

### Option 1: Quick Start (Recommended)

```bash
# Pull and run LocalStack
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

### Option 2: Docker Compose (Recommended with .env file)

**New for 2026**: Use the provided docker-compose.yml with .env.example for easy configuration!

**Features**:
- Docker volume for data persistence (cross-platform compatible)
- Windows support via configurable Docker socket path
- Environment variable configuration via `.env` file
- Resource limits and health checks pre-configured

```bash
# Navigate to LocalStack directory
cd module-01/aws/localstack

# Copy the example environment file
cp .env.example .env

# (Optional) Edit .env to customize your settings
# For Windows users: Check DOCKER_SOCKET_PATH if needed
# nano .env

# Start LocalStack
docker compose up -d

# View logs
docker compose logs -f localstack

# Stop LocalStack when done
docker compose down

# Remove all data including volumes
docker compose down -v
```

**Windows PowerShell**:
```powershell
# Navigate to LocalStack directory
cd module-01\aws\localstack

# Copy the example environment file
copy .env.example .env

# Start LocalStack
docker compose up -d

# View logs
docker compose logs -f localstack

# Stop LocalStack when done
docker compose down -v
```

**Managing Docker Volumes**:
```bash
# List all volumes
docker volume ls

# Inspect LocalStack data volume
docker volume inspect localstack-data

# Backup volume data
docker run --rm -v localstack-data:/data -v $(pwd):/backup alpine tar czf /backup/localstack-backup.tar.gz /data

# Restore volume data
docker run --rm -v localstack-data:/data -v $(pwd):/backup alpine tar xzf /backup/localstack-backup.tar.gz
```

**Or create your own `docker-compose.yml`**:

```yaml
services:
  localstack:
    image: localstack/localstack:latest
    container_name: localstack_main
    ports:
      - "4566:4566"
      - "4510-4559:4510-4559"
    environment:
      - SERVICES=s3,lambda,dynamodb,kinesis,iam,apigateway,sns,sqs,logs
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      # Use Docker volume instead of bind mount for cross-platform compatibility
      - localstack-data:/tmp/localstack/data
      # Docker socket (Linux/macOS default)
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  localstack-data:
    driver: local
```

**Notes**:
- The `version` field in docker-compose.yml is deprecated and no longer required in Docker Compose v2+
- Data is stored in a Docker volume named `localstack-data` for better cross-platform support
- On Windows with Docker Desktop, the Docker socket is usually handled automatically

## Configure AWS CLI

```bash
# Create LocalStack profile
aws configure --profile localstack

# Enter any values for prompts
AWS Access Key ID: test
AWS Secret Access Key: test
Default region name: us-east-1
Default output format: json

# Set environment variable
export AWS_ENDPOINT_URL=http://localhost:4566

# Or add to each command
# aws --endpoint-url=http://localhost:4566 <service> <command>
```

## Verify Installation

```bash
# Check health
curl http://localhost:4566/_localstack/health

# Expected output:
# {"status": "ok"}

# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

## Your First Commands

### 1. Create S3 Bucket

```bash
# Create bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-first-bucket

# Verify
aws --endpoint-url=http://localhost:4566 s3 ls
```

### 2. Create DynamoDB Table

```bash
# Create table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=UserId,AttributeType=S \
    --key-schema AttributeName=UserId,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Verify
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### 3. Create Lambda Function

```bash
# Create handler
mkdir my-lambda && cd my-lambda

cat > handler.py << 'EOF'
def lambda_handler(event, context):
    return {'statusCode': 200, 'body': 'Hello!'}
EOF

# Package
zip function.zip handler.py

# Create function
aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name my-function \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler handler.lambda_handler \
    --zip-file fileb://function.zip

# Verify
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

## 5-Minute Tutorials

### Tutorial 1: S3 + Lambda Integration

```bash
# 1. Create S3 bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket

# 2. Create Lambda that processes S3 events
cat > s3_handler.py << 'EOF'
import json

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"New file: {key} in {bucket}")
    return {'status': 'ok'}
EOF

zip s3.zip s3_handler.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name s3-processor \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler s3_handler.lambda_handler \
    --zip-file fileb://s3.zip

# 3. Upload file to test
echo "test" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://test-bucket/
```

### Tutorial 2: DynamoDB CRUD Operations

```bash
# 1. Create table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Products \
    --attribute-definitions AttributeName=Id,AttributeType=S \
    --key-schema AttributeName=Id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# 2. Put item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Products \
    --item '{"Id": {"S": "prod1"}, "Name": {"S": "Laptop"}, "Price": {"N": "999"}}'

# 3. Get item
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name Products \
    --key '{"Id": {"S": "prod1"}}'

# 4. Update item
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name Products \
    --key '{"Id": {"S": "prod1"}}' \
    --update-expression 'SET Price = :newprice' \
    --expression-attribute-values '{":newprice": {"N": "899"}}'

# 5. Query table
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name Products
```

### Tutorial 3: Kinesis Stream

```bash
# 1. Create stream
aws --endpoint-url=http://localhost:4566 kinesis create-stream \
    --stream-name test-stream \
    --shard-count 1

# 2. Put records
for i in {1..5}; do
    aws --endpoint-url=http://localhost:4566 kinesis put-record \
        --stream-name test-stream \
        --partition-key "key$i" \
        --data "VGVzdCBkYXRhICRp"
done

# 3. Get records
SHARD=$(aws --endpoint-url=http://localhost:4566 kinesis describe-stream \
    --stream-name test-stream \
    --query 'StreamDescription.Shards[0].ShardId' \
    --output text)

ITERATOR=$(aws --endpoint-url=http://localhost:4566 kinesis get-shard-iterator \
    --stream-name test-stream \
    --shard-id $SHARD \
    --shard-iterator-type TRIM_HORIZON \
    --query 'ShardIterator' \
    --output text)

aws --endpoint-url=http://localhost:4566 kinesis get-records \
    --shard-iterator $ITERATOR
```

## Common Commands Reference

### S3 Commands
```bash
# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Create bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://bucket-name

# Upload file
aws --endpoint-url=http://localhost:4566 s3 cp file.txt s3://bucket-name/

# Download file
aws --endpoint-url=http://localhost:4566 s3 cp s3://bucket-name/file.txt ./

# Delete bucket
aws --endpoint-url=http://localhost:4566 s3 rb s3://bucket-name --force
```

### DynamoDB Commands
```bash
# List tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Describe table
aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name TableName

# Put item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name TableName \
    --item '{"key": {"S": "value"}}'

# Get item
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name TableName \
    --key '{"key": {"S": "value"}}'

# Scan table
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name TableName

# Delete table
aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name TableName
```

### Lambda Commands
```bash
# List functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Invoke function
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name FunctionName \
    response.json

# Delete function
aws --endpoint-url=http://localhost:4566 lambda delete-function \
    --function-name FunctionName
```

### IAM Commands
```bash
# List users
aws --endpoint-url=http://localhost:4566 iam list-users

# Create user
aws --endpoint-url=http://localhost:4566 iam create-user --user-name username

# Delete user
aws --endpoint-url=http://localhost:4566 iam delete-user --user-name username

# List roles
aws --endpoint-url=http://localhost:4566 iam list-roles
```

## Troubleshooting

### Port Already in Use

**Linux/macOS**:
```bash
# Find process using port 4566
lsof -ti:4566 | xargs kill -9

# Or use a different port
docker run --rm -it -p 4567:4566 localstack/localstack
```

**Windows PowerShell**:
```powershell
# Find process using port 4566
Get-NetTCPConnection -LocalPort 4566 | Select-Object -Property State, OwningProcess
# Kill the process using the PID
Stop-Process -Id <PID> -Force

# Or use a different port
docker run --rm -it -p 4567:4566 localstack/localstack
```

**Windows Command Prompt**:
```cmd
# Find process using port 4566
netstat -ano | findstr :4566
# Kill the process using the PID
taskkill /PID <PID> /F
```

### Container Not Starting

```bash
# Check Docker is running
docker ps

# Check logs
docker logs localstack_main

# Restart Docker Desktop
```

### Services Not Responding

```bash
# Check health endpoint
curl http://localhost:4566/_localstack/health

# Enable debug mode
docker run --rm -it -e DEBUG=1 -p 4566:4566 localstack/localstack
```

## Next Steps

1. **Explore individual service guides**:
   - `01-compute-services.md` - Lambda and EC2
   - `02-storage-database.md` - S3 and DynamoDB
   - `03-networking-analytics-security.md` - Networking, Analytics, and Security

2. **Practice with hands-on projects**:
   - Build serverless APIs
   - Create data pipelines
   - Implement event-driven architectures

3. **Prepare for CLF-C02 exam**:
   - Focus on services available in FREE tier
   - Use AWS Free Tier for services not in LocalStack
   - Practice with DigitalCloud cheat sheets

## Quick Cleanup

```bash
# If using Docker Compose
docker compose down

# Remove the Docker volume (deletes all LocalStack data)
docker volume rm localstack-data

# Or combine both commands
docker compose down -v  # The -v flag removes associated volumes
```

**Windows PowerShell**:
```powershell
# Stop and remove containers
docker compose down

# Remove the volume
docker volume rm localstack-data

# Or both at once
docker compose down -v
```

## Environment Setup Script

Save this as `setup-localstack.sh`:

```bash
#!/bin/bash

# LocalStack Quick Setup Script (using Docker Compose)
# Make sure you're in the localstack directory

echo "Setting up LocalStack..."

# Check if .env file exists, if not copy from example
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
fi

# Start LocalStack using Docker Compose
echo "Starting LocalStack container with Docker Compose..."
docker compose up -d

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
until curl -s http://localhost:4566/_localstack/health | grep -q "ok"; do
    echo "LocalStack is starting... (this may take 30-60 seconds)"
    sleep 5
done

echo "LocalStack is ready!"
echo ""
echo "Test with:"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls"
echo ""
echo "View logs:"
echo "  docker compose logs -f localstack"
echo ""
echo "Stop LocalStack:"
echo "  docker compose down"
```

**Alternative: Quick Docker Run (Without Compose)**

```bash
#!/bin/bash

# LocalStack Quick Setup Script (using Docker run)

echo "Setting up LocalStack..."

# Start LocalStack
echo "Starting LocalStack container..."
docker run -d --name localstack_main \
    -p 4566:4566 \
    -p 4510-4559:4510-4559 \
    -e SERVICES=s3,lambda,dynamodb,kinesis,iam,apigateway,sns,sqs \
    localstack/localstack

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
until curl -s http://localhost:4566/_localstack/health | grep -q "ok"; do
    echo "LocalStack is starting... (this may take 30-60 seconds)"
    sleep 5
done

echo "LocalStack is ready!"
echo ""
echo "Test with:"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls"
echo ""
echo "View logs:"
echo "  docker logs -f localstack_main"
echo ""
echo "Stop LocalStack:"
echo "  docker stop localstack_main && docker rm localstack_main"
```

Make it executable:

```bash
chmod +x setup-localstack.sh
./setup-localstack.sh
```

---

## Additional Resources

- [Full README](README.md) - Comprehensive LocalStack guide
- [Service Coverage](README.md#service-coverage---free-tier) - Complete service list
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)

---

**Last Updated**: January 2026
