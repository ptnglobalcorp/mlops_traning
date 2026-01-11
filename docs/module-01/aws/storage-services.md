# Domain 3: Storage Services

**CLF-C02 Exam Domain 3 - Part 2 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- Understand Amazon S3 core features and storage classes
- Compare EBS, EFS, and Instance Store
- Identify appropriate storage solutions for use cases
- Understand S3 security and replication options
- Compare storage costs and performance

## Amazon S3 (Simple Storage Service)

### Overview

**Amazon S3** is object storage built to store and retrieve any amount of data from anywhere.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Object Storage** | Store files as "objects" (data + metadata) |
| **Unlimited Storage** | No limit on amount of data |
| **High Durability** | 99.999999999% (11 nines) |
| **High Availability** | 99.99% availability |
| **Scalable** | Virtually unlimited throughput |
| **Low Cost** | Pay for what you use |

### S3 Core Concepts

#### 1. Buckets

**Definition**: Containers for objects stored in S3.

**Bucket Characteristics**:
- **Globally Unique Name**: DNS-compliant name
- **Region**: Bucket resides in a specific region
- **Unlimited Objects**: No limit on objects per bucket

**Naming Rules**:
- 3-63 characters long
- Lowercase letters, numbers, hyphens
- Must start with letter or number
- Must not end with hyphen
- Cannot use `xn--` prefix (punycode)

#### 2. Objects

**Definition**: The fundamental entities stored in S3.

**Object Components**:
- **Key**: Unique identifier (filename + path)
- **Data**: The actual content
- **Metadata**: Information about the object
- **Version ID**: If versioning is enabled

**Example**:
```
Bucket: my-app-bucket
Key: images/2024/photo.jpg
URL: https://my-app-bucket.s3.us-east-1.amazonaws.com/images/2024/photo.jpg
```

#### 3. S3 Storage Classes

**Comparison Table**:

| Storage Class | Design | Durability | Availability | Minimum Storage | Minimum Charge | Use Case |
|---------------|---------|------------|--------------|-----------------|----------------|----------|
| **Standard** | Frequent access | 99.999999999% | 99.99% | None | None | Primary data |
| **Intelligent-Tiering** | Auto tiering | 99.999999999% | 99.9% | 30 days | None | Unknown access patterns |
| **Standard-IA** | Infrequent access | 99.999999999% | 99.9% | 30 days | 30 days | Data accessed less often |
| **One Zone-IA** | Infrequent, one AZ | 99.999999999% | 99.5% | 30 days | 30 days | Secondary copy |
| **Glacier** | Long-term archive | 99.999999999% | 99.99% | None | 90 days | Rarely accessed data |
| **Glacier Deep Archive** | Long-term archive | 99.999999999% | 99.99% | None | 180 days | Rarely accessed, lowest cost |
| **Outposts** | On-premises | 99.999999999% | 99.99% | None | None | On-premises storage |

**Storage Class Decision Tree**:
```
Frequent Access?
  ├─ Yes → S3 Standard
  └─ No
      ├─ Need fastest retrieval (minutes)? → S3 Standard-IA
      ├─ OK with hours? → S3 Glacier Flexible Retrieval
      ├─ OK with 12 hours? → S3 Glacier Deep Archive
      └─ Unknown access pattern? → S3 Intelligent-Tiering
```

#### 4. S3 Features

**Versioning**:
- Keeps multiple versions of an object
- Protects from accidental deletion
- **Once enabled, cannot be disabled** (only suspended)
- **Use Cases**: Backup, data protection, rollback

**Lifecycle Policies**:
- Automatically transition objects between storage classes
- Automatically expire/delete objects
- **Rules**: Based on age, prefix, tags
- **Example**: Move to Standard-IA after 30 days, to Glacier after 90 days

**Encryption**:
- **Server-Side Encryption**:
  - **SSE-S3**: AWS-managed keys
  - **SSE-KMS**: AWS KMS managed keys
  - **SSE-C**: Customer-provided keys
- **Client-Side Encryption**: Encrypt before upload

**Replication**:
- **Same-Region Replication (SRR)**: Copy within region
- **Cross-Region Replication (CRR)**: Copy to different region
- **Requirements**: Versioning enabled, source/dest buckets in different regions
- **Use Cases**: Disaster recovery, compliance, latency reduction

**Event Notifications**:
- S3 can publish events to:
  - **SNS**: Send notifications
  - **SQS**: Queue messages
  - **Lambda**: Trigger functions
- **Events**: Object created, removed, or replicated

**S3 Select**:
- Retrieve subset of data from an object
- **Use Case**: Filter large CSV/JSON files
- **Benefit**: Reduce data transfer and cost

**Requester Pays**:
- Bucket owner doesn't pay for data transfer
- Requester pays for download and transfer
- **Use Case**: Sharing public datasets

#### 5. S3 Security

**Access Control**:

| Feature | Description |
|---------|-------------|
| **Bucket Policies** | JSON-based policies for bucket access |
| **ACLs** | Access Control Lists (legacy) |
| **Block Public Access** | Prevent public access at account/bucket level |
| **Presigned URLs** | Temporary access to private objects |
| **CloudFront OAI** | Grant CloudFront access to private content |

**Bucket Policy Example**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:user/bob"},
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

**Presigned URLs**:
- Temporary access (expires after set time)
- **Use Case**: Share private files without making public
- **CLI**: `aws s3 presign s3://bucket/key --expires-in 3600`

#### 6. S3 Performance

**Optimization Tips**:
- **Parallel Uploads**: Use multipart upload for large files
- **S3 Transfer Acceleration**: Use CloudFront edge locations
- **Byte-Range Fetches**: Get specific byte ranges
- **S3 Transfer Acceleration**: Faster long-distance transfers

---

## Amazon EBS (Elastic Block Store)

### Overview

**Amazon EBS** provides block-level storage volumes for use with EC2 instances.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Block Storage** | Like a hard drive |
| **Persistent** | Data survives instance stop/start |
| **Network-Attached** | Accessed over the network |
| **Single Instance** | One volume attached to one instance |
| **Snapshots** | Point-in-time backups to S3 |

### EBS Volume Types

| Type | Name | IOPS | Throughput | Use Case | Cost |
|------|------|------|------------|----------|------|
| **gp2** | General Purpose SSD | Up to 16,000 | Up to 250 MB/s | Boot volumes, general workloads | Low |
| **gp3** | General Purpose SSD | Up to 16,000 | Up to 1,000 MB/s | Cost-effective, flexible | Lowest |
| **io1** | Provisioned IOPS SSD | Up to 64,000 | Up to 1,000 MB/s | Critical applications, databases | High |
| **io2** | Provisioned IOPS SSD | Up to 256,000 | Up to 4,000 MB/s | Highest performance, enterprise | Highest |
| **st1** | Throughput Optimized HDD | 500 | Up to 500 MB/s | Big data, data warehouses | Low |
| **sc1** | Cold HDD | 250 | Up to 250 MB/s | File servers, log storage | Lowest |

**Volume Selection Guide**:
```
Boot Volume or General Workload?
  ├─ Yes → gp3 (best value, predictable performance)
  └─ No
      ├─ Highest performance needed? → io2
      ├─ Big data, throughput needed? → st1
      └─ infrequent access? → sc1
```

### EBS Snapshots

**Characteristics**:
- Incremental backups (only changed data)
- Stored in S3
- Can create volumes from snapshots
- Cross-region copy for DR
- **Pricing**: Storage ($0.05/GB/month), data transfer

**Snapshot Lifecycle**:
```
Volume → Snapshot → Copy to S3
              └─ Create new volume from snapshot
```

### EBS Encryption

- Enabled at volume creation
- Uses AWS KMS
- Encrypted snapshots only create encrypted volumes
- No performance impact

---

## Amazon EFS (Elastic File System)

### Overview

**Amazon EFS** provides a simple, scalable file system for use with EC2 instances.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **File Storage** | Like NAS, uses NFS protocol |
| **Shared Access** | Multiple instances can access simultaneously |
| **Persistent** | Data survives instance termination |
| **Scalable** | Grows and shrinks automatically |
| **Pay-per-use** | Pay for storage used |

### EFS Performance

**Performance Modes**:

| Mode | Description | Use Case |
|------|-------------|----------|
| **General Purpose** | Lower latency per operation | Most workloads |
| **Max I/O** | Higher latency, higher throughput | Large-scale parallel workloads |

**Throughput Modes**:

| Mode | Description | Cost |
|------|-------------|------|
| **Bursting** | Baseline + credits | Default, lower cost |
| **Provisioned** | Fixed throughput | Higher cost, predictable |

### EFS vs EBS

| Feature | EFS | EBS |
|---------|-----|-----|
| **Access** | Multiple instances | Single instance |
| **Size** | Up to PB | Up to 16 TB (io2) |
| **Protocol** | NFS | Block device |
| **Pricing** | Per GB used | Per GB provisioned |
| **Use Case** | Shared file system, web serving | Boot volume, database |

### EFS Storage Classes

| Class | Description | Cost |
|-------|-------------|------|
| **Standard** | Frequently accessed data | Higher |
| **Infrequent Access (IA)** | Less frequently accessed | Lower |
| **Archive** | Rarely accessed | Lowest |

Lifecycle policy: Move to IA after 30/60/90/180/270 days of no access

---

## S3 Security Deep Dive

### Block Public Access

**Account-Level Settings**:
- Block Public Access (account level)
- Block all public access
- Block public access to buckets and objects granted through new ACLs
- Block public and cross-account access to buckets and objects

**Bucket-Level Settings**:
- Same settings apply to individual bucket

**Best Practice**: Enable Block Public Access for buckets containing sensitive data

### Encryption Options

| Encryption Type | Key Management | Use Case |
|-----------------|----------------|----------|
| **SSE-S3** | AWS-managed | Simple encryption |
| **SSE-KMS** | KMS-managed | Control key policies, audit |
| **SSE-C** | Customer-managed | Full control |
| **DSSE-KMS** | Double-layer KMS | Highest security |

### Encryption in Transit

- **HTTPS**: Secure communication
- **SSL/TLS**: Use presigned URLs with HTTPS
- **VPC Endpoints**: Private connectivity to S3

---

## Exam Tips - Storage Services

### High-Yield Topics

1. **S3 Storage Classes**:
   - Standard = Frequent access
   - Standard-IA = Infrequent access, 30-day minimum
   - Glacier/Deep Archive = Long-term archive, retrieval time
   - Intelligent-Tiering = Auto-tiering based on access

2. **S3 Features**:
   - Versioning = Multiple versions, cannot be disabled (only suspended)
   - Lifecycle policies = Auto transition/delete
   - Replication = CRR for DR, SRR for backup
   - Encryption = SSE-S3, SSE-KMS, SSE-C

3. **EBS vs Instance Store**:
   - EBS = Persistent, network-attached
   - Instance Store = Ephemeral, on-host

4. **EBS Volume Types**:
   - gp2/gp3 = General purpose (gp3 has better price/performance)
   - io1/io2 = High IOPS, databases
   - st1/sc1 = HDD, big data, low cost

5. **EFS**:
   - File storage, NFS protocol
   - Shared across multiple instances
   - Auto-scaling

6. **S3 URLs**:
   - Path-style: `https://s3.region.amazonaws.com/bucket/key`
   - Virtual-hosted: `https://bucket.s3.region.amazonaws.com/key`

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Storage Services Cheat Sheet](https://digitalcloud.training/aws-storage-services/) - Comprehensive storage services reference for exam prep

### Official AWS Documentation
- [Amazon S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Amazon EBS Documentation](https://docs.aws.amazon.com/ebs/)
- [Amazon EFS Documentation](https://docs.aws.amazon.com/efs/)
- [S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/)
- [AWS Skill Builder Storage Training](https://skillbuilder.aws/) - Free storage courses and certification prep
- [AWS Storage Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive storage learning paths
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on storage labs and practice environments

### AWS Storage Resources
- [S3 Pricing](https://aws.amazon.com/s3/pricing/) - Current storage pricing
- [EBS Pricing](https://aws.amazon.com/ebs/pricing/) - Block storage pricing
- [EFS Pricing](https://aws.amazon.com/efs/pricing/) - File storage pricing
- [S3 Glacier Pricing](https://aws.amazon.com/s3/glacier/pricing/) - Archive storage pricing

---

**Next**: [Database Services](database-services.md)
