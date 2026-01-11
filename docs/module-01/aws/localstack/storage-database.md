# LocalStack: Storage & Database Services Guide

**Hands-on Practice for S3, EBS, DynamoDB**

> **Note**: Bash commands in this guide work on Linux, macOS, and Windows (via Git Bash, WSL, or PowerShell with bash support).

## Overview

This guide provides hands-on exercises for AWS Storage and Database services using LocalStack's FREE tier.

## Services Available in FREE Tier

### Storage Services

| Service | Available | Notes |
|---------|-----------|-------|
| **S3** | ✅ Yes | Full S3 API support |
| **S3 Control** | ✅ Yes | Control plane operations |
| **EBS** | ✅ Yes | Included with EC2 mock |
| **EFS** | ❌ No | Requires Base tier |
| **S3 Glacier** | ❌ No | Requires Base tier |

### Database Services

| Service | Available | Notes |
|---------|-----------|-------|
| **DynamoDB** | ✅ Yes | Full DynamoDB support |
| **DynamoDB Streams** | ✅ Yes | Streams included |
| **RDS** | ❌ No | Requires Base tier |
| **ElastiCache** | ❌ No | Requires Base tier |
| **Aurora** | ❌ No | Part of RDS (Base tier) |

---

## Part 1: Amazon S3 (Simple Storage Service)

### Basic S3 Operations

```bash
# Create a bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket

# List all buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Create multiple buckets
aws --endpoint-url=http://localhost:4566 s3 mb s3://data-bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://backup-bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://logs-bucket
```

### Upload and Download Objects

```bash
# Create test files
echo "Hello S3!" > file1.txt
echo "Another file" > file2.txt
mkdir -p data/subfolder
echo "Nested file" > data/subfolder/nested.txt

# Upload single file
aws --endpoint-url=http://localhost:4566 s3 cp file1.txt s3://my-test-bucket/

# Upload multiple files
aws --endpoint-url=http://localhost:4566 s3 cp file2.txt s3://my-test-bucket/
aws --endpoint-url=http://localhost:4566 s3 cp data/ s3://my-test-bucket/data/ --recursive

# List objects in bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-test-bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-test-bucket/data/ --recursive

# Download file
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-test-bucket/file1.txt downloaded-file.txt

# Download entire bucket
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-test-bucket/ ./downloaded/ --recursive
```

### S3 Object Operations

```bash
# Get object metadata
aws --endpoint-url=http://localhost:4566 s3api head-object \
    --bucket my-test-bucket \
    --key file1.txt

# Copy object within bucket
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-test-bucket/file1.txt s3://my-test-bucket/file1-copy.txt

# Move object (copy + delete)
aws --endpoint-url=http://localhost:4566 s3 mv s3://my-test-bucket/file1-copy.txt s3://my-test-bucket/renamed.txt

# Delete object
aws --endpoint-url=http://localhost:4566 s3 rm s3://my-test-bucket/renamed.txt

# Delete multiple objects
aws --endpoint-url=http://localhost:4566 s3 rm s3://my-test-bucket/file2.txt s3://my-test-bucket/data/subfolder/nested.txt
```

### S3 Versioning

```bash
# Enable versioning on bucket
aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning \
    --bucket my-test-bucket \
    --versioning-configuration Status=Enabled

# Check versioning status
aws --endpoint-url=http://localhost:4566 s3api get-bucket-versioning \
    --bucket my-test-bucket

# Upload multiple versions
echo "Version 1" > document.txt
aws --endpoint-url=http://localhost:4566 s3 cp document.txt s3://my-test-bucket/

echo "Version 2" > document.txt
aws --endpoint-url=http://localhost:4566 s3 cp document.txt s3://my-test-bucket/

echo "Version 3" > document.txt
aws --endpoint-url=http://localhost:4566 s3 cp document.txt s3://my-test-bucket/

# List object versions
aws --endpoint-url=http://localhost:4566 s3api list-object-versions \
    --bucket my-test-bucket \
    --prefix document.txt
```

### S3 Lifecycle Policies

```bash
# Create lifecycle policy configuration
cat > lifecycle.json << 'EOF'
{
  "Rules": [
    {
      "ID": "DeleteOldFiles",
      "Status": "Enabled",
      "Prefix": "logs/",
      "Expiration": {
        "Days": 30
      }
    }
  ]
}
EOF

# Apply lifecycle policy
aws --endpoint-url=http://localhost:4566 s3api put-bucket-lifecycle-configuration \
    --bucket my-test-bucket \
    --lifecycle-configuration file://lifecycle.json

# Get lifecycle configuration
aws --endpoint-url=http://localhost:4566 s3api get-bucket-lifecycle-configuration \
    --bucket my-test-bucket
```

### S3 Bucket Policies

```bash
# Create bucket policy
cat > bucket-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-test-bucket/*"
    }
  ]
}
EOF

# Apply bucket policy
aws --endpoint-url=http://localhost:4566 s3api put-bucket-policy \
    --bucket my-test-bucket \
    --policy file://bucket-policy.json

# Get bucket policy
aws --endpoint-url=http://localhost:4566 s3api get-bucket-policy \
    --bucket my-test-bucket

# Delete bucket policy
aws --endpoint-url=http://localhost:4566 s3api delete-bucket-policy \
    --bucket my-test-bucket
```

### S3 Website Hosting

```bash
# Create website configuration
cat > website-config.json << 'EOF'
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "error.html"
  }
}
EOF

# Enable website hosting
aws --endpoint-url=http://localhost:4566 s3api put-bucket-website \
    --bucket my-test-bucket \
    --website-configuration file://website-config.json

# Get website configuration
aws --endpoint-url=http://localhost:4566 s3api get-bucket-website \
    --bucket my-test-bucket

# Upload website files
echo "<html><body>Hello World</body></html>" > index.html
aws --endpoint-url=http://localhost:4566 s3 cp index.html s3://my-test-bucket/
```

### Sync Operations

```bash
# Sync local directory to S3
mkdir -p local-data
echo "File 1" > local-data/file1.txt
echo "File 2" > local-data/file2.txt

aws --endpoint-url=http://localhost:4566 s3 sync local-data/ s3://my-test-bucket/

# Sync S3 to local directory
aws --endpoint-url=http://localhost:4566 s3 sync s3://my-test-bucket/ local-downloaded/

# Delete files not in source
aws --endpoint-url=http://localhost:4566 s3 sync local-data/ s3://my-test-bucket/ --delete
```

---

## Part 2: Amazon DynamoDB

### Create Table Operations

```bash
# Create a simple table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Users \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Create table with composite key
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Orders \
    --attribute-definitions \
        AttributeName=CustomerId,AttributeType=S \
        AttributeName=OrderId,AttributeType=S \
    --key-schema \
        AttributeName=CustomerId,KeyType=HASH \
        AttributeName=OrderId,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Create table with GSI
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Products \
    --attribute-definitions \
        AttributeName=ProductId,AttributeType=S \
        AttributeName=Category,AttributeType=S \
        AttributeName=Name,AttributeType=S \
    --key-schema \
        AttributeName=ProductId,KeyType=HASH \
    --global-secondary-indexes \
        "[
            {
                \"IndexName\": \"CategoryIndex\",
                \"KeySchema\": [
                    {\"AttributeName\":\"Category\",\"KeyType\":\"HASH\"}
                ],
                \"Projection\": {
                    \"ProjectionType\":\"ALL\"
                }
            }
        ]" \
    --billing-mode PAY_PER_REQUEST

# List all tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Describe table
aws --endpoint-url=http://localhost:4566 dynamodb describe-table \
    --table-name Users
```

### CRUD Operations

```bash
# Put item (Create/Update)
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Users \
    --item '{
        "UserId": {"S": "user123"},
        "Username": {"S": "john_doe"},
        "Email": {"S": "john@example.com"},
        "Age": {"N": "30"},
        "Active": {"BOOL": true}
    }'

# Get item (Read)
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name Users \
    --key '{
        "UserId": {"S": "user123"}
    }'

# Update item
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name Users \
    --key '{
        "UserId": {"S": "user123"}
    }' \
    --update-expression 'SET #A = :newAge' \
    --expression-attribute-names '{
        "#A": "Age"
    }' \
    --expression-attribute-values '{
        ":newAge": {"N": "31"}
    }'

# Update item (add attribute)
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name Users \
    --key '{
        "UserId": {"S": "user123"}
    }' \
    --update-expression 'SET City = :city' \
    --expression-attribute-values '{
        ":city": {"S": "New York"}
    }'

# Delete item
aws --endpoint-url=http://localhost:4566 dynamodb delete-item \
    --table-name Users \
    --key '{
        "UserId": {"S": "user123"}
    }'
```

### Query Operations

```bash
# Query with composite key
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Orders \
    --key-condition-expression 'CustomerId = :cid' \
    --expression-attribute-values '{
        ":cid": {"S": "customer123"}
    }'

# Query with sort key condition
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Orders \
    --key-condition-expression 'CustomerId = :cid AND OrderId > :oid' \
    --expression-attribute-values '{
        ":cid": {"S": "customer123"},
        ":oid": {"S": "order100"}
    }'

# Query with filter
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Users \
    --key-condition-expression 'UserId = :uid' \
    --filter-expression '#A > :minAge' \
    --expression-attribute-names '{
        "#A": "Age"
    }' \
    --expression-attribute-values '{
        ":uid": {"S": "user123"},
        ":minAge": {"N": "25"}
    }'
```

### Scan Operations

```bash
# Scan entire table
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name Users

# Scan with filter
aws --endpoint-url=http://localhost:4566 dynamodb scan \
    --table-name Users \
    --filter-expression 'Active = :active' \
    --expression-attribute-values '{
        ":active": {"BOOL": true}
    }'

# Scan with projection (select specific attributes)
aws --endpoint-url=http://localhost:4566 dynamodb scan \
    --table-name Users \
    --projection-expression 'UserId, Username, Email'

# Scan with limit
aws --endpoint-url=http://localhost:4566 dynamodb scan \
    --table-name Users \
    --limit 10
```

### Batch Operations

```bash
# Batch write
aws --endpoint-url=http://localhost:4566 dynamodb batch-write-item \
    --request-items '{
        "Users": [
            {
                "PutRequest": {
                    "Item": {
                        "UserId": {"S": "user1"},
                        "Username": {"S": "alice"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "UserId": {"S": "user2"},
                        "Username": {"S": "bob"}
                    }
                }
            }
        ]
    }'

# Batch get
aws --endpoint-url=http://localhost:4566 dynamodb batch-get-item \
    --request-items '{
        "Users": {
            "Keys": [
                {"UserId": {"S": "user1"}},
                {"UserId": {"S": "user2"}}
            ]
        }
    }'
```

### DynamoDB Streams

```bash
# Enable streams on table
aws --endpoint-url=http://localhost:4566 dynamodb update-table \
    --table-name Users \
    --stream-viewport-type NEW_IMAGE

# Describe streams
aws --endpoint-url=http://localhost:4566 dynamodb describe-stream \
    --stream-arn arn:aws:dynamodb:us-east-1:000000000000:table/Users/stream/2025-01-01T00:00:00.000

# Get shard iterator
SHARD_ITERATOR=$(aws --endpoint-url=http://localhost:4566 dynamodbstreams get-shard-iterator \
    --stream-arn arn:aws:dynamodb:us-east-1:000000000000:table/Users/stream/2025-01-01T00:00:00.000 \
    --shard-id shardId-000000000000 \
    --shard-iterator-type LATEST \
    --query 'ShardIterator' \
    --output text)

# Get records from stream
aws --endpoint-url=http://localhost:4566 dynamodbstreams get-records \
    --shard-iterator $SHARD_ITERATOR
```

### Provisioned Mode (Optional)

```bash
# Create table with provisioned capacity
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name ProvisionedTable \
    --attribute-definitions \
        AttributeName=Id,AttributeType=S \
    --key-schema \
        AttributeName=Id,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5

# Update provisioned capacity
aws --endpoint-url=http://localhost:4566 dynamodb update-table \
    --table-name ProvisionedTable \
    --provisioned-throughput \
        ReadCapacityUnits=10,WriteCapacityUnits=10
```

---

## Part 3: Hands-On Projects

### Project 1: S3 + DynamoDB Application

```bash
# Create S3 bucket for data storage
aws --endpoint-url=http://localhost:4566 s3 mb s3://data-lake

# Create DynamoDB table for metadata
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name FileMetadata \
    --attribute-definitions \
        AttributeName=FileName,AttributeType=S \
    --key-schema \
        AttributeName=FileName,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Upload files and track metadata
for i in {1..5}; do
    filename="data_$i.txt"
    echo "Content $i" > $filename

    # Upload to S3
    aws --endpoint-url=http://localhost:4566 s3 cp $filename s3://data-lake/

    # Store metadata in DynamoDB
    filesize=$(stat -f%z $filename 2>/dev/null || stat -c%s $filename 2>/dev/null || echo "100")

    aws --endpoint-url=http://localhost:4566 dynamodb put-item \
        --table-name FileMetadata \
        --item "{
            \"FileName\": {\"S\": \"$filename\"},
            \"Size\": {\"N\": \"$filesize\"},
            \"Location\": {\"S\": \"s3://data-lake/$filename\"},
            \"UploadDate\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}
        }"
done

# Query metadata
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name FileMetadata

# List all files in S3
aws --endpoint-url=http://localhost:4566 s3 ls s3://data-lake/
```

### Project 2: Multi-Condition Query Pattern

```bash
# Create tables with different access patterns
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Games \
    --attribute-definitions \
        AttributeName=GameId,AttributeType=S \
        AttributeName=Genre,AttributeType=S \
        AttributeName=Platform,AttributeType=S \
    --key-schema \
        AttributeName=GameId,KeyType=HASH \
    --global-secondary-indexes \
        "[
            {
                \"IndexName\": \"GenreIndex\",
                \"KeySchema\": [
                    {\"AttributeName\":\"Genre\",\"KeyType\":\"HASH\"}
                ],
                \"Projection\": {\"ProjectionType\":\"ALL\"}
            },
            {
                \"IndexName\": \"PlatformIndex\",
                \"KeySchema\": [
                    {\"AttributeName\":\"Platform\",\"KeyType\":\"HASH\"}
                ],
                \"Projection\": {\"ProjectionType\":\"ALL\"}
            }
        ]" \
    --billing-mode PAY_PER_REQUEST

# Insert sample data
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Games \
    --item '{
        "GameId": {"S": "game1"},
        "Title": {"S": "Racing Game"},
        "Genre": {"S": "Racing"},
        "Platform": {"S": "PS5"},
        "Rating": {"N": "4.5"}
    }'

# Query by primary key
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Games \
    --key-condition-expression 'GameId = :gid' \
    --expression-attribute-values '{":gid": {"S": "game1"}}'

# Query by genre (GSI)
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Games \
    --index-name GenreIndex \
    --key-condition-expression 'Genre = :genre' \
    --expression-attribute-values '{":genre": {"S": "Racing"}}'

# Query by platform (GSI)
aws --endpoint-url=http://localhost:4566 dynamodb query \
    --table-name Games \
    --index-name PlatformIndex \
    --key-condition-expression 'Platform = :plat' \
    --expression-attribute-values '{":plat": {"S": "PS5"}}'
```

---

## Part 4: Practice Exercises

### Exercise 1: S3 Versioning Workflow

1. Create a bucket and enable versioning
2. Upload multiple versions of the same file
3. List all versions
4. Download a specific version

### Exercise 2: DynamoDB Counter Pattern

```bash
# Create counter table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name Counters \
    --attribute-definitions AttributeName=CounterName,AttributeType=S \
    --key-schema AttributeName=CounterName,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Initialize counter
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Counters \
    --item '{"CounterName": {"S": "PageViews"}, "Count": {"N": "0"}}'

# Increment counter
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name Counters \
    --key '{"CounterName": {"S": "PageViews"}}' \
    --update-expression 'SET #C = #C + :inc' \
    --expression-attribute-names '{"#C": "Count"}' \
    --expression-attribute-values '{":inc": {"N": "1"}}'

# Get current count
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
    --table-name Counters \
    --key '{"CounterName": {"S": "PageViews"}}'
```

### Exercise 3: Conditional Writes

```bash
# Implement "create if not exists"
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Users \
    --item '{
        "UserId": {"S": "unique_user"},
        "Email": {"S": "user@example.com"}
    }' \
    --condition-expression 'attribute_not_exists(UserId)'

# This will fail if user already exists
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name Users \
    --item '{
        "UserId": {"S": "unique_user"},
        "Email": {"S": "newemail@example.com"}
    }' \
    --condition-expression 'attribute_not_exists(UserId)'
```

### Exercise 4: Batch Upload

```bash
# Upload 100 items to DynamoDB
for i in {1..100}; do
    aws --endpoint-url=http://localhost:4566 dynamodb put-item \
        --table-name Users \
        --item "{
            \"UserId\": {\"S\": \"user$i\"},
            \"Username\": {\"S\": \"username$i\"},
            \"Index\": {\"N\": \"$i\"}
        }"
done

# Verify count
aws --endpoint-url=http://localhost:4566 dynamodb scan \
    --table-name Users \
    --select 'COUNT'
```

---

## Part 5: Cleanup Commands

```bash
# Delete all S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls \
    --query 'Buckets[].Name' \
    --output text | while read bucket; do
    aws --endpoint-url=http://localhost:4566 s3 rb s3://$bucket --force
done

# Delete all DynamoDB tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables \
    --query 'TableNames[]' \
    --output text | while read table; do
    aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name $table
done
```

---

## Additional Resources

### Documentation
- [Amazon S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Amazon DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [LocalStack S3 Guide](https://docs.localstack.cloud/user-guide/aws/s3/)
- [LocalStack DynamoDB Guide](https://docs.localstack.cloud/user-guide/aws/dynamodb/)

### DigitalCloud Cheat Sheets
- [AWS Storage Services Cheat Sheet](https://digitalcloud.training/aws-storage-services/)
- [AWS Database Services Cheat Sheet](https://digitalcloud.training/aws-database-services/)

---

**Last Updated**: January 2026
