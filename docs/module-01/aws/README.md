# AWS Cloud Services (CLF-C02)

**Comprehensive AWS documentation aligned with AWS Certified Cloud Practitioner (CLF-C02) exam domains**

## Quick Start

Practice AWS services locally with LocalStack:
```bash
cd module-01/aws
docker compose up -d
```

## CLF-C02 Exam Domains

The AWS Certified Cloud Practitioner (CLF-C02) exam consists of **4 content domains**:

| Domain | Percentage | Description |
|--------|-----------|-------------|
| **Domain 1: Cloud Concepts** | 26% | Cloud computing concepts, cloud benefits, cloud economics |
| **Domain 2: Security and Compliance** | 25% | Shared responsibility model, security concepts, AWS security services |
| **Domain 3: Core Services** | 33% | Compute, storage, database, networking, analytics, global infrastructure |
| **Domain 4: Migration and Optimization** | 16% | Deployment methods, billing, pricing, support |

---

## Domain 1: Cloud Concepts (26%)

### Documentation
- [Cloud Concepts](cloud-concepts.md) - Cloud computing fundamentals

### Key Topics
- Cloud computing concepts (6 advantages of cloud computing)
- Cloud economics (CapEx vs OpEx, Total Cost of Ownership)
- Cloud adoption strategies

---

## Domain 2: Security and Compliance (25%)

### Documentation
- [Security & Compliance](security-compliance.md) - Shared responsibility model, IAM, security services

### Key Topics
- AWS Shared Responsibility Model
- Identity and Access Management (IAM)
- AWS security services (KMS, Shield, WAF, GuardDuty)
- Compliance and governance

---

## Domain 3: Core Services (33%)

### Deployment & Operating Methods
- [Deployment Methods](deployment-methods.md) - Console, CLI, SDK, CloudFormation, CDK, Terraform

### Compute Services
- [Compute Services](compute-services.md) - EC2, Lambda, Elastic Beanstalk

### Storage Services
- [Storage Services](storage-services.md) - S3, EBS, EFS

### Database Services
- [Database Services](database-services.md) - RDS, DynamoDB, ElastiCache

### Networking Services & Global Infrastructure
- [Networking Services](networking-services.md) - VPC, Route 53, CloudFront, Global Infrastructure

### Analytics Services
- [Analytics Services](analytics-services.md) - QuickSight, Athena, Redshift, Kinesis

### AI/ML Services
- [AI/ML Services](ai-ml-services.md) - SageMaker AI, Rekognition, Comprehend, Lex, Polly, Transcribe, and more

---

## Domain 4: Migration and Optimization (16%)

### Documentation
- [Billing & Pricing](billing-pricing.md) - Pricing models, billing, support plans

### Key Topics
- Pricing models (On-Demand, Reserved, Spot, Savings Plans)
- Billing and cost management tools
- Support plans (Basic, Developer, Business, Enterprise)
- Migration strategies

---

## LocalStack Practice Environment

Practice AWS services locally with LocalStack (supports CLF-C02 exam services):

```
localstack/
├── quick-start.md                     # 5-minute setup guide
├── guide.md                           # Comprehensive LocalStack guide
├── compute.md                         # Lambda and EC2 practice
├── storage-database.md                # S3 and DynamoDB practice
└── networking-analytics-security.md   # Advanced topics
```

### Services Available for Practice

LocalStack FREE tier supports:
- **Compute**: EC2, Lambda
- **Storage**: S3
- **Database**: DynamoDB
- **Networking**: API Gateway, VPC components
- **Analytics**: Kinesis, CloudWatch Logs
- **Security**: IAM
- **Messaging**: SNS, SQS

### LocalStack Setup

```bash
# Navigate to the lab
cd module-01/aws

# Copy environment configuration
cp .env.example .env

# Start LocalStack
docker compose up -d

# Check health
curl http://localhost:4566/_localstack/health

# Practice S3
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-test-bucket
```

---

## Service Reference

### Compute Services
| Service | Description | Use Case |
|---------|-------------|----------|
| **EC2** | Elastic Compute Cloud | Virtual servers in the cloud |
| **Lambda** | Serverless compute | Event-driven functions |
| **Elastic Beanstalk** | PaaS | Easy application deployment |

### Storage Services
| Service | Description | Use Case |
|---------|-------------|----------|
| **S3** | Simple Storage Service | Object storage |
| **EBS** | Elastic Block Store | Block storage for EC2 |
| **EFS** | Elastic File System | Network file storage |

### Database Services
| Service | Description | Type |
|---------|-------------|------|
| **RDS** | Relational Database Service | SQL databases |
| **DynamoDB** | NoSQL database | NoSQL key-value |
| **ElastiCache** | In-memory cache | Redis/Memcached |

### Networking Services
| Service | Description | Purpose |
|---------|-------------|---------|
| **VPC** | Virtual Private Cloud | Isolated network |
| **Route 53** | DNS service | Domain routing |
| **CloudFront** | CDN | Content delivery |

### AI/ML Services
| Service | Description | Purpose |
|---------|-------------|---------|
| **SageMaker AI** | ML platform | Build custom ML models |
| **Rekognition** | Image/video analysis | Computer vision |
| **Comprehend** | NLP service | Text analysis |
| **Transcribe** | Speech-to-text | Audio transcription |
| **Polly** | Text-to-speech | Voice synthesis |
| **Translate** | Language translation | Neural ML translation |
| **Textract** | Document extraction | OCR and form data |
| **Lex** | Conversational AI | Chatbots |

### Deployment Tools
| Tool | Description | Purpose |
|------|-------------|---------|
| **CloudFormation** | AWS-native IaC | Infrastructure as code |
| **AWS CDK** | Code-based IaC | Developer-friendly IaC |
| **Terraform** | Multi-cloud IaC | Provider-agnostic IaC |
| **AWS CLI** | Command-line tool | Scripting/administration |
| **AWS SDKs** | Language APIs | Application development |

---

## Additional Resources

### Official AWS Resources
- [AWS Certified Cloud Practitioner Exam Guide](https://docs.aws.amazon.com/aws-certification/latest/examguides/cloud-practitioner-02.html)
- [AWS Certification Homepage](https://aws.amazon.com/certification/certified-cloud-practitioner/)
- [AWS Documentation](https://docs.aws.amazon.com/)

### Study Resources
- [DigitalCloud.training Cheat Sheets](https://digitalcloud.training/) - Quick reference guides for all CLF-C02 topics
- [LocalStack Documentation](https://docs.localstack.cloud/)

---

**Lab Location:** [`../../module-01/aws/`](../../module-01/aws/) - LocalStack practice environment
