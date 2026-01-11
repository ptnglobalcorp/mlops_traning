# LocalStack: Networking, Analytics & Security Services Guide

**Hands-on Practice for Networking, Analytics, and Security Services**

> **Note**: Bash commands in this guide work on Linux, macOS, and Windows (via Git Bash, WSL, or PowerShell with bash support).

## Overview

This guide provides hands-on exercises for AWS Networking, Analytics, and Security services using LocalStack's FREE tier.

## Services Available in FREE Tier

### Networking Services

| Service | Available | Notes |
|---------|-----------|-------|
| **Route 53** | ✅ Yes | DNS mock implementation |
| **API Gateway (REST)** | ✅ Yes | Full REST API support |
| **API Gateway (HTTP)** | ❌ No | Requires Base tier |
| **CloudFront** | ❌ No | Requires Base tier |
| **VPC** | ✅ Yes | VPC mock available |
| **ELB/ELBv2** | ❌ No | Requires Base tier |

### Analytics Services

| Service | Available | Notes |
|---------|-----------|-------|
| **Kinesis Data Streams** | ✅ Yes | Full Kinesis support |
| **Kinesis Data Firehose** | ✅ Yes | Firehose delivery |
| **Kinesis Data Analytics** | ❌ No | Requires Base tier |
| **Athena** | ❌ No | Requires Ultimate tier |
| **Redshift** | ✅ Yes | Redshift mock |
| **EMR** | ❌ No | Requires Ultimate tier |
| **Glue** | ❌ No | Requires Ultimate tier |
| **OpenSearch** | ✅ Yes | Full search service |
| **QuickSight** | ❌ No | Not available |
| **MSK** | ❌ No | Requires Base tier |

### Security Services

| Service | Available | Notes |
|---------|-----------|-------|
| **IAM** | ✅ Yes | Full IAM support |
| **KMS** | ✅ Yes | Key management mock |
| **Secrets Manager** | ✅ Yes | Secrets storage |
| **Certificate Manager** | ✅ Yes | SSL certificate mock |
| **STS** | ✅ Yes | Security Token Service |
| **Cognito** | ❌ No | Requires Base tier |
| **WAF** | ❌ No | Requires Base tier |
| **Shield** | ❌ No | Requires Base tier |

---

## Part 1: Networking Services

### 1. API Gateway (REST API)

```bash
# Create REST API
API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-rest-api \
    --name "my-api" \
    --description "My first API" \
    --query 'id' \
    --output text)

echo "Created API: $API_ID"

# Get the root resource ID
ROOT_ID=$(aws --endpoint-url=http://localhost:4566 apigateway get-resources \
    --rest-api-id $API_ID \
    --query 'items[0].id' \
    --output text)

# Create a resource
RESOURCE_ID=$(aws --endpoint-url=http://localhost:4566 apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_ID \
    --path-part "users" \
    --query 'id' \
    --output text)

echo "Created resource: $RESOURCE_ID"

# Create GET method
aws --endpoint-url=http://localhost:4566 apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method GET \
    --authorization-type NONE

# Create Lambda integration
cat > api_lambda.py << 'EOF'
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            'users': [
                {'id': 1, 'name': 'Alice'},
                {'id': 2, 'name': 'Bob'}
            ]
        })
    }
EOF

zip function.zip api_lambda.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name api-handler \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler api_lambda.lambda_handler \
    --zip-file fileb://function.zip

# Create integration
aws --endpoint-url=http://localhost:4566 apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:api-handler/invocations

# Deploy API
aws --endpoint-url=http://localhost:4566 apigateway create-deployment \
    --rest-api-id $API_ID \
    --stage-name prod

# Get API URL
API_URL="http://localhost:4566/restapis/$API_ID/prod/_user_request_"
echo "API URL: $API_URL"

# Test the API
curl "$API_URL/users"
```

### 2. Route 53 (DNS Service)

```bash
# Create hosted zone
HOSTED_ZONE_ID=$(aws --endpoint-url=http://localhost:4566 route53 create-hosted-zone \
    --name example.com \
    --caller-reference "my-ref-$(date +%s)" \
    --query 'HostedZone.Id' \
    --output text)

echo "Created hosted zone: $HOSTED_ZONE_ID"

# List hosted zones
aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones

# Create record set
aws --endpoint-url=http://localhost:4566 route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.example.com",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "192.0.2.1"}]
            }
        }]
    }'

# List record sets
aws --endpoint-url=http://localhost:4566 route53 list-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID
```

### 3. VPC (Virtual Private Cloud)

```bash
# Create VPC
VPC_ID=$(aws --endpoint-url=http://localhost:4566 ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --query 'Vpc.VpcId' \
    --output text)

echo "Created VPC: $VPC_ID"

# Create subnet
SUBNET_ID=$(aws --endpoint-url=http://localhost:4566 ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Created subnet: $SUBNET_ID"

# Describe VPC
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs \
    --vpc-ids $VPC_ID

# Describe subnets
aws --endpoint-url=http://localhost:4566 ec2 describe-subnets \
    --subnet-ids $SUBNET_ID

# Delete subnet
aws --endpoint-url=http://localhost:4566 ec2 delete-subnet --subnet-id $SUBNET_ID

# Delete VPC
aws --endpoint-url=http://localhost:4566 ec2 delete-vpc --vpc-id $VPC_ID
```

---

## Part 2: Analytics Services

### 1. Kinesis Data Streams

```bash
# Create a Kinesis stream
aws --endpoint-url=http://localhost:4566 kinesis create-stream \
    --stream-name my-data-stream \
    --shard-count 2

# List streams
aws --endpoint-url=http://localhost:4566 kinesis list-streams

# Describe stream
aws --endpoint-url=http://localhost:4566 kinesis describe-stream \
    --stream-name my-data-stream

# Put records
for i in {1..10}; do
    aws --endpoint-url=http://localhost:4566 kinesis put-record \
        --stream-name my-data-stream \
        --partition-key "key-$i" \
        --data "SGVsbG8gS2luZXNpcyEkeSE="
done

# Get shard iterator
SHARD_ITERATOR=$(aws --endpoint-url=http://localhost:4566 kinesis get-shard-iterator \
    --stream-name my-data-stream \
    --shard-id shardId-000000000000 \
    --shard-iterator-type TRIM_HORIZON \
    --query 'ShardIterator' \
    --output text)

# Get records from stream
aws --endpoint-url=http://localhost:4566 kinesis get-records \
    --shard-iterator $SHARD_ITERATOR

# Split shard (increase capacity)
aws --endpoint-url=http://localhost:4566 kinesis split-shard \
    --stream-name my-data-stream \
    --shard-to-split shardId-000000000000 \
    --new-starting-hash-key 170141183460469231731687303715884105727

# Delete stream
aws --endpoint-url=http://localhost:4566 kinesis delete-stream \
    --stream-name my-data-stream
```

### 2. Kinesis Data Firehose

```bash
# Create S3 bucket for Firehose delivery
aws --endpoint-url=http://localhost:4566 s3 mb s3://firehose-delivery

# Create Firehose delivery stream
aws --endpoint-url=http://localhost:4566 firehose create-delivery-stream \
    --delivery-stream-name my-firehose-stream \
    --s3-destination-configuration '{
        "RoleARN": "arn:aws:iam::000000000000:role/firehose-role",
        "BucketARN": "arn:aws:s3:::firehose-delivery"
    }'

# Describe delivery stream
aws --endpoint-url=http://localhost:4566 firehose describe-delivery-stream \
    --delivery-stream-name my-firehose-stream

# List delivery streams
aws --endpoint-url=http://localhost:4566 firehose list-delivery-streams

# Put record
aws --endpoint-url=http://localhost:4566 firehose put-record \
    --delivery-stream-name my-firehose-stream \
    --record-data "Test data for Firehose"

# Delete delivery stream
aws --endpoint-url=http://localhost:4566 firehose delete-delivery-stream \
    --delivery-stream-name my-firehose-stream
```

### 3. Amazon OpenSearch (Elasticsearch)

```bash
# Create domain
aws --endpoint-url=http://localhost:4566 opensearch create-domain \
    --domain-name my-search-domain \
    --engine-version OpenSearch_1.0

# List domains
aws --endpoint-url=http://localhost:4566 opensearch list-domain-names

# Describe domain
aws --endpoint-url=http://localhost:4566 opensearch describe-domain \
    --domain-name my-search-domain

# Delete domain
aws --endpoint-url=http://localhost:4566 opensearch delete-domain \
    --domain-name my-search-domain
```

### 4. Redshift (Data Warehouse)

```bash
# Create cluster
aws --endpoint-url=http://localhost:4566 redshift create-cluster \
    --cluster-identifier my-redshift-cluster \
    --node-type dc2.large \
    --number-of-nodes 2 \
    --master-username admin \
    --master-user-password Password123 \
    --db-name dev

# Describe clusters
aws --endpoint-url=http://localhost:4566 redshift describe-clusters

# Delete cluster
aws --endpoint-url=http://localhost:4566 redshift delete-cluster \
    --cluster-identifier my-redshift-cluster \
    --skip-final-cluster-snapshot
```

---

## Part 3: Security Services

### 1. IAM (Identity and Access Management)

```bash
# Create user
aws --endpoint-url=http://localhost:4566 iam create-user \
    --user-name test-user

# List users
aws --endpoint-url=http://localhost:4566 iam list-users

# Create access key for user
aws --endpoint-url=http://localhost:4566 iam create-access-key \
    --user-name test-user

# Create group
aws --endpoint-url=http://localhost:4566 iam create-group \
    --group-name developers

# Add user to group
aws --endpoint-url=http://localhost:4566 iam add-user-to-group \
    --group-name developers \
    --user-name test-user

# Create managed policy
cat > s3-read-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws --endpoint-url=http://localhost:4566 iam create-policy \
    --policy-name S3ReadPolicy \
    --policy-document file://s3-read-policy.json

# Attach policy to user
aws --endpoint-url=http://localhost:4566 iam attach-user-policy \
    --user-name test-user \
    --policy-arn arn:aws:iam::000000000000:policy/S3ReadPolicy

# List attached policies
aws --endpoint-url=http://localhost:4566 iam list-attached-user-policies \
    --user-name test-user

# Create role
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

# List roles
aws --endpoint-url=http://localhost:4566 iam list-roles

# Delete user
aws --endpoint-url=http://localhost:4566 iam delete-user --user-name test-user

# Delete group
aws --endpoint-url=http://localhost:4566 iam delete-group --group-name developers

# Delete role
aws --endpoint-url=http://localhost:4566 iam delete-role --role-name lambda-execution-role
```

### 2. KMS (Key Management Service)

```bash
# Create KMS key
KEY_ID=$(aws --endpoint-url=http://localhost:4566 kms create-key \
    --description "My test key" \
    --query 'KeyMetadata.KeyId' \
    --output text)

echo "Created KMS key: $KEY_ID"

# List keys
aws --endpoint-url=http://localhost:4566 kms list-keys

# Describe key
aws --endpoint-url=http://localhost:4566 kms describe-key \
    --key-id $KEY_ID

# Encrypt data
PLAIN_TEXT="Hello KMS!"
ENCRYPTED=$(aws --endpoint-url=http://localhost:4566 kms encrypt \
    --key-id $KEY_ID \
    --plaintext "$PLAIN_TEXT" \
    --query 'CiphertextBlob' \
    --output text)

echo "Encrypted: $ENCRYPTED"

# Decrypt data
DECRYPTED=$(aws --endpoint-url=http://localhost:4566 kms decrypt \
    --ciphertext-blob "$ENCRYPTED" \
    --plaintext file://./decrypted.txt \
    --output text)

cat decrypted.txt

# Generate data key
aws --endpoint-url=http://localhost:4566 kms generate-data-key \
    --key-id $KEY_ID \
    --key-spec AES_256

# Schedule key deletion
aws --endpoint-url=http://localhost:4566 kms schedule-key-deletion \
    --key-id $KEY_ID \
    --pending-window-in-days 7
```

### 3. Secrets Manager

```bash
# Create secret
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
    --name my-database-secret \
    --secret-string '{
        "username": "admin",
        "password": "SecretPassword123",
        "host": "localhost",
        "port": "5432"
    }'

# List secrets
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets

# Get secret value
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
    --secret-id my-database-secret

# Update secret
aws --endpoint-url=http://localhost:4566 secretsmanager update-secret \
    --secret-id my-database-secret \
    --secret-string '{
        "username": "admin",
        "password": "NewPassword456",
        "host": "localhost",
        "port": "5432"
    }'

# Delete secret
aws --endpoint-url=http://localhost:4566 secretsmanager delete-secret \
    --secret-id my-database-secret \
    --force-delete-without-recovery
```

### 4. Certificate Manager

```bash
# Import certificate
aws --endpoint-url=http://localhost:4566 acm import-certificate \
    --certificate fileb://certificate.pem \
    --private-key fileb://private-key.pem \
    --certificate-chain fileb://certificate-chain.pem

# List certificates
aws --endpoint-url=http://localhost:4566 acm list-certificates

# Describe certificate
aws --endpoint-url=http://localhost:4566 acm describe-certificate \
    --certificate-arn arn:aws:acm:us-east-1:000000000000:certificate/12345678-1234-1234-1234-123456789012

# Delete certificate
aws --endpoint-url=http://localhost:4566 acm delete-certificate \
    --certificate-arn arn:aws:acm:us-east-1:000000000000:certificate/12345678-1234-1234-1234-123456789012
```

---

## Part 4: Application Integration Services

### 1. SNS (Simple Notification Service)

```bash
# Create SNS topic
TOPIC_ARN=$(aws --endpoint-url=http://localhost:4566 sns create-topic \
    --name my-topic \
    --query 'TopicArn' \
    --output text)

echo "Created topic: $TOPIC_ARN"

# List topics
aws --endpoint-url=http://localhost:4566 sns list-topics

# Subscribe to topic (email)
aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol email \
    --notification-endpoint user@example.com

# Subscribe to topic (HTTP)
SUBSCRIPTION_ARN=$(aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol http \
    --notification-endpoint http://localhost:8080/endpoint \
    --query 'SubscriptionArn' \
    --output text)

# List subscriptions
aws --endpoint-url=http://localhost:4566 sns list-subscriptions

# Publish message
aws --endpoint-url=http://localhost:4566 sns publish \
    --topic-arn $TOPIC_ARN \
    --message "Hello from SNS!"

# Unsubscribe
aws --endpoint-url=http://localhost:4566 sns unsubscribe \
    --subscription-arn $SUBSCRIPTION_ARN

# Delete topic
aws --endpoint-url=http://localhost:4566 sns delete-topic \
    --topic-arn $TOPIC_ARN
```

### 2. SQS (Simple Queue Service)

```bash
# Create queue
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name my-queue \
    --query 'QueueUrl' \
    --output text)

echo "Created queue: $QUEUE_URL"

# Create FIFO queue
FIFO_QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name my-fifo-queue.fifo \
    --attributes FifoQueue=true \
    --query 'QueueUrl' \
    --output text)

# List queues
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Send message
aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url $QUEUE_URL \
    --message "Hello from SQS!"

# Receive message
MESSAGE=$(aws --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url $QUEUE_URL)

echo "Received: $MESSAGE"

# Get queue attributes
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
    --queue-url $QUEUE_URL \
    --attribute-names All

# Purge queue
aws --endpoint-url=http://localhost:4566 sqs purge-queue \
    --queue-url $QUEUE_URL

# Delete queue
aws --endpoint-url=http://localhost:4566 sqs delete-queue \
    --queue-url $QUEUE_URL
```

### 3. Step Functions

```bash
# Create state machine definition
cat > state-machine.json << 'EOF'
{
  "Comment": "A simple minimal example",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:000000000000:function:hello-world",
      "End": true
    }
  }
}
EOF

# Create state machine
aws --endpoint-url=http://localhost:4566 stepfunctions create-state-machine \
    --name my-state-machine \
    --definition file://state-machine.json \
    --role-arn arn:aws:iam::000000000000:role/states-role

# List state machines
aws --endpoint-url=http://localhost:4566 stepfunctions list-state-machines

# Describe state machine
aws --endpoint-url=http://localhost:4566 stepfunctions describe-state-machine \
    --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:my-state-machine

# Start execution
aws --endpoint-url=http://localhost:4566 stepfunctions start-execution \
    --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:my-state-machine \
    --input '{}'

# Delete state machine
aws --endpoint-url=http://localhost:4566 stepfunctions delete-state-machine \
    --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:my-state-machine
```

---

## Part 5: Hands-On Projects

### Project 1: Serverless Data Pipeline

```bash
# Create Kinesis stream
aws --endpoint-url=http://localhost:4566 kinesis create-stream \
    --stream-name data-pipeline-stream \
    --shard-count 1

# Create S3 bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://pipeline-output

# Create Firehose delivery stream
aws --endpoint-url=http://localhost:4566 firehose create-delivery-stream \
    --delivery-stream-name kinesis-to-s3 \
    --s3-destination-configuration '{
        "RoleARN": "arn:aws:iam::000000000000:role/firehose-role",
        "BucketARN": "arn:aws:s3:::pipeline-output"
    }'

# Create Lambda processor
cat > processor.py << 'EOF'
import json

def lambda_handler(event, context):
    for record in event['Records']:
        # Process Kinesis record
        data = record['kinesis']['data']
        print(f"Processing: {data}")

    return {'status': 'success'}
EOF

zip function.zip processor.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name data-processor \
    --runtime python3.9 \
    --role arn:aws:iam::000000000000:role/test-role \
    --handler processor.lambda_handler \
    --zip-file fileb://function.zip

# Put test data
aws --endpoint-url=http://localhost:4566 kinesis put-record \
    --stream-name data-pipeline-stream \
    --partition-key test \
    --data "VGVzdCBkYXRh"
```

### Project 2: Event-Driven Architecture

```bash
# Create SNS topic
TOPIC_ARN=$(aws --endpoint-url=http://localhost:4566 sns create-topic \
    --name events-topic \
    --query 'TopicArn' \
    --output text)

# Create SQS queue
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs create-queue \
    --queue-name events-queue \
    --query 'QueueUrl' \
    --output text)

# Subscribe queue to topic
aws --endpoint-url=http://localhost:4566 sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol sqs \
    --notification-endpoint $QUEUE_URL

# Publish event
aws --endpoint-url=http://localhost:4566 sns publish \
    --topic-arn $TOPIC_ARN \
    --message '{"event": "user_created", "user_id": "123"}'

# Process event
aws --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url $QUEUE_URL
```

---

## Part 6: Practice Exercises

### Exercise 1: IAM Policy Management

1. Create IAM user
2. Create custom policy for S3 read-only access
3. Attach policy to user
4. Verify user permissions

### Exercise 2: KMS Encryption Workflow

1. Create KMS key
2. Encrypt sample data
3. Decrypt and verify
4. Schedule key deletion

### Exercise 3: Complete API Gateway Setup

1. Create REST API
2. Add resources and methods
3. Integrate with Lambda
4. Deploy and test

### Exercise 4: Kinesis Stream Processing

1. Create Kinesis stream
2. Produce records
3. Consume records
4. Test shard operations

---

## Part 7: Cleanup Commands

```bash
# Delete all SNS topics
aws --endpoint-url=http://localhost:4566 sns list-topics \
    --query 'Topics[].TopicArn' \
    --output text | while read topic; do
    aws --endpoint-url=http://localhost:4566 sns delete-topic --topic-arn $topic
done

# Delete all SQS queues
aws --endpoint-url=http://localhost:4566 sqs list-queues \
    --query 'QueueUrls[]' \
    --output text | while read queue; do
    aws --endpoint-url=http://localhost:4566 sqs delete-queue --queue-url $queue
done

# Delete all Kinesis streams
aws --endpoint-url=http://localhost:4566 kinesis list-streams \
    --query 'StreamNames[]' \
    --output text | while read stream; do
    aws --endpoint-url=http://localhost:4566 kinesis delete-stream --stream-name $stream
done
```

---

## Additional Resources

### Documentation
- [AWS Kinesis Documentation](https://docs.aws.amazon.com/kinesis/)
- [AWS SNS Documentation](https://docs.aws.amazon.com/sns/)
- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [LocalStack Kinesis Guide](https://docs.localstack.cloud/user-guide/aws/kinesis/)

### DigitalCloud Cheat Sheets
- [AWS Analytics Services Cheat Sheet](https://digitalcloud.training/aws-analytics-services/)
- [AWS Security Services Cheat Sheet](https://digitalcloud.training/aws-security-services/)
- [AWS Networking Services Cheat Sheet](https://digitalcloud.training/aws-networking-services/)

---

**Last Updated**: January 2026
