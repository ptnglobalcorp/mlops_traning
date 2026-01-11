# Domain 3: Compute Services

**CLF-C02 Exam Domain 3 - Part 1 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- Understand Amazon EC2 core components
- Compare EC2 purchasing options
- Understand serverless compute with AWS Lambda
- Identify use cases for different compute services
- Compare container and orchestration services

## Amazon EC2 (Elastic Compute Cloud)

### Overview

**Amazon EC2** provides scalable computing capacity in the AWS Cloud. You can launch virtual servers (instances) and configure security and networking.

### EC2 Core Components

#### 1. Amazon Machine Image (AMI)

**Definition**: A template that contains the software configuration (operating system, application server, and applications).

**AMI Types**:
- **Amazon Linux**: AWS-optimized Linux
- **Ubuntu**: Popular Linux distribution
- **Windows Server**: Microsoft Windows
- **RHEL**: Red Hat Enterprise Linux

**AMI Sources**:
- AWS-provided (Quick Start AMIs)
- Community AMIs (from other AWS customers)
- Marketplace AMIs (from vendors)
- Custom AMIs (created by you)

**Relationship**:
```
AMI (Template)
    │
    └── Launch → Instance (Running Server)
```

#### 2. Instance Types

**Definition**: The combination of CPU, memory, storage, and networking capacity.

**Instance Type Naming**:
```
[Instance Family].[Generation].[Size within Family]
Example: m5.2xlarge
         │  │  └─ 2xlarge = Size (larger = more resources)
         │  └─ 5 = Generation (newer = better performance/price)
         └─ m = Family (general purpose)
```

**Instance Families**:

| Family | Name | Use Case | vCPU | Memory | Example Types |
|--------|------|----------|------|--------|---------------|
| **General Purpose** | m, t | Balance of compute, memory, networking | 1-128 | 1-512 GB | t3.micro, m5.large |
| **Compute Optimized** | c | Compute-intensive applications | 1-128 | 2-256 GB | c5.large, c6g.xlarge |
| **Memory Optimized** | r, x, z | Memory-intensive applications | 1-128 | 16-3,904 GB | r5.large, x1e.32xlarge |
| **Accelerated Computing** | p, g, inf | GPU/accelerator applications | 4-96 | 64-768 GB | p3.2xlarge, g4dn.xlarge |
| **Storage Optimized** | i, d, h | High storage throughput | 2-128 | 8-384 GB | i3.large, d3.xlarge |

**Common Instance Types**:

| Instance | vCPU | Memory | Use Case |
|----------|------|--------|----------|
| **t3.micro** | 2 | 1 GB | Development, testing |
| **t3.medium** | 2 | 4 GB | Small web server |
| **m5.large** | 2 | 8 GB | General purpose |
| **c5.large** | 2 | 4 GB | Compute optimized |
| **r5.large** | 2 | 16 GB | Memory optimized |
| **m5.2xlarge** | 8 | 32 GB | Production applications |

**Burstable Instances (t-series)**:
- **Baseline CPU**: Credit accumulation during idle
- **CPU Credits**: Spend for burst performance
- **Unlimited**: Can burst beyond credits (extra charge)
- **Standard**: Limited to credit balance

#### 3. Instance Purchasing Options

**Comparison Table**:

| Option | Cost | Commitment | Best For | Discount |
|--------|------|------------|----------|----------|
| **On-Demand** | Highest | None | Short-term, flexible workloads | 0% |
| **Reserved** | Lower | 1-3 years | Steady-state, predictable workloads | Up to 75% |
| **Spot** | Lowest | None | Fault-tolerant, flexible workloads | Up to 90% |
| **Dedicated** | Highest | 3 years | Compliance, licensing | No discount |

**On-Demand Instances**:
- Pay by the second (Linux) or hour (Windows)
- No long-term commitment
- Highest cost, maximum flexibility
- **Use Cases**:
  - Development/testing
  - Short-term projects
  - Unpredictable workloads

**Reserved Instances (RIs)**:
- Commitment to 1-year or 3-year term
- Payment options: All Upfront, Partial Upfront, No Upfront
- Up to 75% savings compared to On-Demand
- **Use Cases**:
  - Production workloads
  - Steady-state usage
  - Long-term applications

**Spot Instances**:
- Use spare EC2 capacity
- Price based on supply and demand
- AWS can interrupt with 2-minute notice
- Up to 90% savings compared to On-Demand
- **Use Cases**:
  - Batch processing
  - Data analysis
  - Background jobs
  - Fault-tolerant applications

**Dedicated Instances**:
- Physical server dedicated to your account
- No hardware-level sharing
- **Use Cases**:
  - Compliance requirements
  - Licensing restrictions
  - Regulatory requirements

#### 4. Security Groups

**Definition**: Virtual firewall that controls inbound and outbound traffic for EC2 instances.

**Key Characteristics**:
- **Stateful**: Return traffic automatically allowed
- **Rule-based**: Allow rules only (no deny rules)
- **Instance-level**: Applied at the instance level
- **Protocol**: IPv4 and IPv6 support

**Default Behavior**:
- **Inbound**: All traffic denied by default
- **Outbound**: All traffic allowed by default

**Example Rules**:
```
Inbound:
  - HTTP (TCP 80) from 0.0.0.0/0
  - HTTPS (TCP 443) from 0.0.0.0/0
  - SSH (TCP 22) from your IP

Outbound:
  - All traffic (default)
```

**Security Group vs NACL**:
| Feature | Security Group | NACL |
|---------|---------------|------|
| Scope | Instance level | Subnet level |
| State | Stateful | Stateless |
| Rules | Allow only | Allow and Deny |
| Order | All rules evaluated | Numbered order |

#### 5. Key Pairs

**Purpose**: Secure login information for your EC2 instances.

**Components**:
- **Public Key**: Stored in AWS (attached to instance)
- **Private Key**: Downloaded and stored securely by you

**Use Cases**:
- SSH access to Linux instances
- RDP password decryption for Windows instances

**Best Practice**: Never share private keys, store securely

#### 6. Elastic IP (EIP)

**Definition**: Static IPv4 address designed for dynamic cloud computing.

**Characteristics**:
- Static public IP address
- Can be remapped to any instance in your account
- **Cost**: Free when attached to running instance, otherwise charged

**Use Cases**:
- Static IP for dynamic instances
- DNS A records pointing to IP
- Failover scenarios

#### 7. EC2 Storage Options

**Comparison**:

| Storage | Type | Persistence | Use Case |
|---------|------|-------------|----------|
| **EBS** | Block storage | Persistent | Boot volumes, database storage |
| **Instance Store** | Block storage | Ephemeral | Temporary storage, caching |
| **EFS** | File storage | Persistent | Shared file system across instances |
| **S3** | Object storage | Persistent | Object storage, backups |

**EBS (Elastic Block Store)**:
- Network-attached block storage
- Persistent (data survives instance stop/start)
- Can be attached to one instance at a time
- Snapshots for backup

**EBS Volume Types**:
| Type | Name | Use Case | Cost |
|------|------|----------|------|
| **gp2/gp3** | General Purpose SSD | Boot volumes, low-latency | Low |
| **io1/io2** | Provisioned IOPS SSD | High-performance databases | High |
| **st1** | Throughput Optimized HDD | Big data, data warehousing | Medium |
| **sc1** | Cold HDD | File servers, log storage | Low |

**Instance Store**:
- Physically attached to host
- Ephemeral (data lost if instance stopped)
- High I/O performance
- Use case: Temporary buffers, caching

#### 8. Placement Groups

**Definition**: Logical grouping of instances within a single AZ.

**Types**:

| Type | Description | Use Case | Network |
|------|-------------|----------|---------|
| **Cluster** | Low latency, high throughput | HPC, Cassandra | 10 Gbps, low latency |
| **Spread** | Instances on distinct hardware | Reduce correlated failures | Standard |
| **Partition** | Instances on partitions | Large distributed workloads | Standard |

#### 9. Auto Scaling

**Purpose**: Automatically scale EC2 capacity based on demand.

**Components**:
- **Auto Scaling Group**: Collection of EC2 instances
- **Scaling Policies**: Rules for when to scale
- **Launch Template**: Configuration for new instances

**Scaling Strategies**:
1. **Manual Scaling**: Change min/max/desired capacity
2. **Dynamic Scaling**: Scale based on metrics (CPU, network)
3. **Scheduled Scaling**: Scale based on time
4. **Predictive Scaling**: ML-based scaling prediction

**Health Checks**:
- EC2 status checks
- ELB health checks
- Unhealthy instances terminated and replaced

---

## AWS Lambda (Serverless Compute)

### Overview

**AWS Lambda** is a serverless compute service that runs code in response to events and automatically manages the compute resources.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Serverless** | No server provisioning or management |
| **Event-driven** | Triggered by events or HTTP requests |
| **Automatic Scaling** | Scales to handle traffic |
| **Pay-per-use** | Pay for compute time (milliseconds) |
| **High Availability** | Built-in availability across AZs |

### Lambda Pricing

**Free Tier**: 1 million requests per month, 400,000 GB-seconds of compute time

**Pricing Model**:
- **Request Price**: Per million requests ($0.20 per million)
- **Duration Price**: Per GB-second (memory × duration)

**Example**:
- 256 MB memory, 1 second duration = 0.5 GB-second
- 1,024 MB memory, 10 seconds = 10 GB-seconds

### Lambda Components

#### 1. Lambda Function

**Definition**: Code that Lambda runs.

**Supported Languages**:
- Python, Node.js, Java, C#, Go, Ruby
- Custom runtime (any language)

#### 2. Triggers (Event Sources)

**Trigger Types**:

| Category | Services | Example |
|----------|----------|---------|
| **Synchronous** | API Gateway, Cognito, Alexa | User waits for response |
| **Asynchronous** | S3, SNS, CloudWatch Events | Background processing |
| **Polling** | Kinesis Streams, DynamoDB Streams | Lambda polls for changes |
| **Stream** | DynamoDB Streams, Kinesis | Ordered processing |

**Common Triggers**:
- **API Gateway**: HTTP endpoints → Lambda
- **S3**: Object uploads → Lambda processing
- **SNS**: Messages → Lambda
- **DynamoDB Streams**: Table changes → Lambda
- **CloudWatch Events**: Scheduled tasks → Lambda
- **Cognito**: User authentication → Lambda

#### 3. Lambda Limits

| Resource | Limit |
|----------|-------|
| **Memory** | 128 MB - 10 GB (64 MB increments) |
| **Timeout** | 1 second - 15 minutes |
| **Deployment Package** | 50 MB (zipped), 250 MB (unzipped) |
| **Environment Variables** | 4 KB |
| **Concurrent Executions** | 1,000 (default, can increase) |

### Lambda Use Cases

| Use Case | Description | Example |
|----------|-------------|---------|
| **Web Applications** | API backend | REST API with API Gateway |
| **Data Processing** | ETL, file processing | S3 upload triggers Lambda |
| **Real-time Processing** | Stream processing | Kinesis data streams |
| **IoT Backends** | Device telemetry | IoT button triggers Lambda |
| **Chatbots** | Natural language processing | Alexa skills |
| **Automation** | Scheduled tasks | CloudWatch Events |

### Lambda vs EC2

| Feature | Lambda | EC2 |
|---------|--------|-----|
| **Management** | No server management | Manage servers |
| **Scaling** | Automatic scaling | Manual or Auto Scaling |
| **Pricing** | Pay per millisecond | Pay per hour |
| **Cold Starts** | Yes | No |
| **Runtime** | Limited execution time | Unlimited |
| **Use Case** | Event-driven, short tasks | Long-running, full control |

---

## Other Compute Services

### 1. AWS Elastic Beanstalk

**Purpose**: Platform as a Service (PaaS) for easy application deployment.

**Characteristics**:
- Upload code, Beanstalk provisions resources
- Supports multiple languages: Java, .NET, Node.js, Python, etc.
- Managed platforms: Tomcat, Docker, Go, etc.
- **You manage**: Application code, configuration
- **AWS manages**: Infrastructure, scaling, load balancing

**Architecture**:
```
Your Code
    │
    ▼
Elastic Beanstalk
    │
    ├── Auto Scaling Group
    ├── Elastic Load Balancer
    ├── EC2 Instances
    ├── RDS (optional)
    └── CloudWatch Alarms
```

### 2. AWS Batch

**Purpose**: Batch processing at any scale.

**Features**:
- Automatically provisions compute resources
- Schedules jobs on optimal EC2 instances
- Integrates with Spot Instances
- **Use Cases**: Data processing, simulations, rendering

### 3. AWS Fargate

**Purpose**: Serverless compute for containers.

**Characteristics**:
- Run containers without managing servers
- Works with ECS and EKS
- Pay for vCPU and memory resources
- **Use Cases**: Containerized applications, microservices

### 4. AWS Lightsail

**Purpose**: Easy-to-use virtual private server (VPS).

**Features**:
- Fixed pricing (simple)
- Bundled resources: instance, storage, DNS, monitoring
- Low-cost entry point
- **Use Cases**: Simple web applications, testing, development

### 5. Outposts

**Purpose**: AWS infrastructure on-premises.

**Features**:
- Fully managed AWS hardware
- Same AWS services, APIs, tools
- **Use Cases**: Data residency, low latency, local data processing

---

## Exam Tips - Compute Services

### High-Yield Topics

1. **EC2 Components**:
   - AMI = Template, Instance = Running server
   - Security Groups = Stateful firewall, allow rules only
   - Key Pairs = SSH access (private key kept secure)

2. **Instance Types**:
   - t-series = Burstable (credits)
   - m-series = General purpose
   - c-series = Compute optimized
   - r-series = Memory optimized

3. **Purchasing Options**:
   - On-Demand = No commitment, highest cost
   - Reserved = 1-3 years, up to 75% savings
   - Spot = Up to 90% savings, interruptible
   - Dedicated = Physical isolation, compliance

4. **Storage**:
   - EBS = Persistent, network-attached
   - Instance Store = Ephemeral, on-host
   - EFS = Network file system, shared

5. **Lambda**:
   - Serverless, event-driven
   - Pay per millisecond
   - Auto scaling
   - Triggers: API Gateway, S3, SNS, DynamoDB

6. **Beanstalk**: PaaS, AWS manages infrastructure

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Compute Services Cheat Sheet](https://digitalcloud.training/aws-compute-services/) - Comprehensive compute services reference for exam prep

### Official AWS Documentation
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [AWS Skill Builder Compute Training](https://skillbuilder.aws/) - Free compute courses and certification prep
- [Domain 3 Practice: Cloud Technology and Services](https://skillbuilder.aws/learn/KK7SC1E2SA/domain-3-practice-aws-certified-cloud-practitioner-clfc02--english/A7JW4ZST3G) - Official compute domain training
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on compute labs and practice environments

### AWS Compute Resources
- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/) - Pay-per-use compute pricing
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/) - Latest instance families
- [AWS Fargate](https://aws.amazon.com/fargate/) - Serverless container compute
- [AWS Batch](https://aws.amazon.com/batch/) - Batch processing at any scale

---

**Next**: [Storage Services](storage-services.md)
