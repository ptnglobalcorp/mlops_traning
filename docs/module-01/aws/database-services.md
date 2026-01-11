# Domain 3: Database Services

**CLF-C02 Exam Domain 3 - Part 3 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- Understand Amazon RDS features and capabilities
- Compare RDS, DynamoDB, and ElastiCache
- Identify use cases for different database services
- Understand Multi-AZ and Read Replicas
- Compare SQL and NoSQL databases

## Amazon RDS (Relational Database Service)

### Overview

**Amazon RDS** is a managed relational database service that provides cost-efficient and resizable capacity.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Managed Service** | AWS handles provisioning, patching, backup, recovery |
| **Supports 6 Engines** | MySQL, PostgreSQL, Oracle, SQL Server, MariaDB, Aurora |
| **Scalable** | Scale compute and storage independently |
| **High Availability** | Multi-AZ deployments |
| **Automatic Backups** | Point-in-time recovery |

### RDS Components

#### 1. DB Instances

**Definition**: An isolated database environment in the cloud.

**Instance Classes**:
- **Burstable**: t3.micro, t3.small (development, testing)
- **General Purpose**: m5 (balanced)
- **Memory Optimized**: r5, x1e (high memory requirements)
- **Compute Optimized**: c5 (high CPU)

#### 2. DB Engine Options

| Engine | Type | Use Case | License Included |
|--------|------|----------|------------------|
| **MySQL** | Open source | Web applications | Yes |
| **PostgreSQL** | Open source | Enterprise apps, GIS | Yes |
| **MariaDB** | Open source | MySQL-compatible | Yes |
| **Oracle** | Commercial | Enterprise applications | No (License Required) |
| **SQL Server** | Commercial | Windows applications | No (License Required) |
| **Aurora** | Proprietary | High-performance, cloud-native | Yes |

### RDS High Availability Features

#### 1. Multi-AZ Deployment

**Purpose**: High availability and durability.

**How It Works**:
```
Primary DB Instance (AZ1)
         │
         └─ Synchronous Replication
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
   Standby Instance (AZ2)   Automatic Failover
```

**Characteristics**:
- **Synchronous replication** to standby instance
- **Automatic failover** to standby if primary fails
- **Same endpoint** for applications (no DNS change)
- **Separate AZ** for standby

**Use Cases**: Production databases, critical applications

**Note**: Multi-AZ is for HA, not read scaling

#### 2. Read Replicas

**Purpose**: Scale read capacity and improve performance.

**How It Works**:
```
Primary DB Instance
    │ (Write)
    ├─ Read Replica 1 (AZ1) ──┐
    ├─ Read Replica 2 (AZ2) ──┤─ Read Traffic
    └─ Read Replica 3 (AZ3) ──┘
```

**Characteristics**:
- **Asynchronous replication** from primary
- **Up to 15 read replicas** (MySQL, PostgreSQL)
- **Separate endpoints** for each replica
- **Can be in different regions**
- **Must be in same region** as Multi-AZ (if enabled)

**Use Cases**:
- Read-intensive applications
- Reporting and analytics
- Disaster recovery (cross-region replicas)

**Note**: Read Replicas are for read scaling, not HA

#### 3. Automated Backups

**Features**:
- **Point-in-time recovery** (PITR)
- **Retention**: 1-35 days
- **Backup window**: Configurable time
- **Snapshots**: Stored in S3

#### 4. Database Snapshots

**Types**:

| Type | Description | Use Case |
|------|-------------|----------|
| **Automated** | During backup window | Point-in-time recovery |
| **Manual** | On-demand | Before changes, long-term backup |

**Characteristics**:
- Stored in S3
- Can create new DB instance from snapshot
- Cross-region snapshot copy

### RDS Security

**Feature**:

| Security Feature | Description |
|------------------|-------------|
| **VPC** | Deploy within VPC for network isolation |
| **Security Groups** | Control access at network level |
| **Encryption at Rest** | Using AWS KMS |
| **Encryption in Transit** | SSL/TLS |
| **IAM** | Control who can manage RDS resources |
| **Master User** | Database authentication (username/password) |

---

## Amazon Aurora

### Overview

**Amazon Aurora** is a fully managed relational database engine compatible with MySQL and PostgreSQL.

### Key Characteristics

| Feature | Aurora vs RDS |
|---------|---------------|
| **Performance** | Up to 5x MySQL, 3x PostgreSQL |
| **Storage** | Auto-scaling up to 128 TB |
| **Availability** | 2 replicas in 3 AZs (storage) |
| **Replication** | Faster (under 1 second) |
| **Cost** | Higher than RDS MySQL/PostgreSQL |

### Aurora Cluster Architecture

```
┌─────────────────────────────────────────────┐
│            Aurora Cluster                   │
├─────────────────────────────────────────────┤
│                                             │
│   Primary Instance (Writer)                 │
│   ┌─┬─┬─┬─┬─┬─┬─┬─┬─┐                    │
│   └─┴─┴─┴─┴─┴─┴─┴─┴─┘ (Shared Storage)     │
│       │       │       │                    │
│   Reader  Reader  Reader (Aurora Replicas) │
│                                             │
└─────────────────────────────────────────────┘
```

**Features**:
- **Storage is distributed** across 3 AZs (automatically)
- **Up to 15 Aurora Replicas** for read scaling
- **Instant failover** (typically < 30 seconds)
- **Backtrack**: Rewind database to specific time (up to 72 hours)

### Aurora Serverless

**Characteristics**:
- On-demand database
- Auto-scaling compute capacity
- Pay per second
- **Use Cases**: Infrequent applications, unpredictable workloads

---

## Amazon DynamoDB

### Overview

**Amazon DynamoDB** is a fully managed NoSQL database service that provides fast and predictable performance.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **NoSQL** | Key-value and document data |
| **Managed** | No server provisioning |
| **Scalable** | Unlimited throughput and storage |
| **Fast** | Single-digit millisecond latency |
| **Pay-per-use** | Pay for read/write capacity |

### DynamoDB Core Concepts

#### 1. Tables

**Definition**: Collection of items.

**Primary Keys**:
- **Partition Key (Hash Key)**: Unique value for each item
- **Partition Key + Sort Key (Composite)**: Unique combination

#### 2. Items

**Definition**: Individual data records (like rows in SQL).

**Attributes**: Key-value pairs (like columns in SQL)

**Example Item**:
```json
{
  "UserId": "user123",           // Partition Key
  "Timestamp": "2024-01-15",     // Sort Key
  "Message": "Hello World",
  "Likes": 42
}
```

### DynamoDB Capacity Modes

| Mode | Description | Pricing |
|------|-------------|---------|
| **On-Demand** | No capacity planning | Pay per request |
| **Provisioned** | Specify RCUs and WCUs | Pay for capacity |

**On-Demand**:
- No capacity planning needed
- Handles unpredictable traffic
- Higher cost than provisioned

**Provisioned**:
- **RCU**: Read Capacity Units (1 RCU = 1 strongly consistent read per second for 4 KB)
- **WCU**: Write Capacity Units (1 WCU = 1 write per second for 1 KB)
- **Auto Scaling**: Adjusts based on traffic

### DynamoDB Features

**DAX (DynamoDB Accelerator)**:
- In-memory cache
- Up to 10x performance improvement
- Reduces read cost

**TTL (Time To Live)**:
- Automatic data deletion
- **Use Case**: Session data, logs, time-series data

**Streams**:
- Capture item modifications
- **Use Case**: Triggers, replication, analytics

**Global Tables**:
- Multi-region, multi-master replication
- **Use Case**: Global applications, low latency

**On-Demand Backup**:
- Full backups anytime
- No performance impact
- Retained until deleted

---

## Amazon ElastiCache

### Overview

**Amazon ElastiCache** is a managed in-memory cache service.

### Supported Engines

| Engine | Type | Use Case |
|--------|------|----------|
| **Redis** | In-memory data store | Caching, pub/sub, leaderboards |
| **Memcached** | Simple memory cache | Simple caching, session state |

### ElastiCache Use Cases

| Use Case | Description |
|----------|-------------|
| **Caching** | Reduce database load |
| **Session State** | Store user sessions |
| **Leaderboards** | Game leaderboards (Redis sorted sets) |
| **Pub/Sub** | Real-time messaging (Redis) |
| **Real-time Analytics** | Counters, analytics |

### ElastiCache vs DynamoDB

| Feature | ElastiCache | DynamoDB |
|---------|-------------|----------|
| **Type** | In-memory cache | Persistent database |
| **Latency** | Sub-millisecond | Single-digit milliseconds |
| **Persistence** | Optional (Redis) | Yes |
| **Use Case** | Cache, session state | Primary database |

---

## Database Service Comparison

### SQL vs NoSQL

| Aspect | SQL (RDS) | NoSQL (DynamoDB) |
|--------|-----------|-----------------|
| **Schema** | Fixed schema | Flexible schema |
| **Scaling** | Vertical | Horizontal |
| **Query Language** | SQL | Native API |
| **Transactions** | ACID | ACID (for single item) |
| **Use Case** | Structured data, complex queries | Rapid growth, flexible schema |

### When to Use Which

**Use RDS when**:
- You need relational database features
- Complex queries and joins
- ACID transactions across multiple tables
- Existing SQL applications

**Use DynamoDB when**:
- You need single-digit millisecond latency
- Your data access patterns are simple
- You need to scale throughput
- Your data model is simple (key-value)

**Use ElastiCache when**:
- You need to cache frequently accessed data
- You need session storage
- You need pub/sub functionality

---

## Exam Tips - Database Services

### High-Yield Topics

1. **RDS Multi-AZ vs Read Replicas**:
   - Multi-AZ = Synchronous replication, HA, same endpoint
   - Read Replicas = Asynchronous replication, read scaling, separate endpoints

2. **Aurora**:
   - AWS proprietary database
   - 5x faster than MySQL
   - Storage auto-scaling (up to 128 TB)
   - 2 replicas in 3 AZs (storage level)

3. **DynamoDB**:
   - NoSQL, key-value/document
   - Single-digit millisecond latency
   - On-demand vs Provisioned capacity
   - Partition Key (+ Sort Key)

4. **ElastiCache**:
   - In-memory cache
   - Redis and Memcached
   - Caching, session state, leaderboards

5. **Backup/Restore**:
   - RDS: Automated backups (1-35 days), snapshots
   - DynamoDB: On-demand backup, PITR (up to 35 days)

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Database Services Cheat Sheet](https://digitalcloud.training/aws-database-services/) - Comprehensive database services reference for exam prep

### Official AWS Documentation
- [Amazon RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Amazon Aurora Documentation](https://docs.aws.amazon.com/aurora/)
- [Amazon DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Amazon ElastiCache Documentation](https://docs.aws.amazon.com/elasticache/)
- [AWS Skill Builder](https://skillbuilder.aws/) - Free database courses and certification prep
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on database labs and practice environments
- [AWS Database Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive database learning paths

### AWS Database Resources
- [Amazon RDS Pricing](https://aws.amazon.com/rds/pricing/) - Current database pricing
- [Aurora Pricing](https://aws.amazon.com/rds/aurora/pricing/) - Cloud-native database pricing
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/) - NoSQL database pricing
- [ElastiCache Pricing](https://aws.amazon.com/elasticache/pricing/) - In-memory cache pricing

---

**Next**: [Networking Services](networking-services.md)
