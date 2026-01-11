# Domain 3: Analytics Services

**CLF-C02 Exam Domain 3 - Part 5 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- Understand AWS analytics services overview
- Compare Amazon QuickSight, Athena, and Redshift
- Identify use cases for different analytics services
- Understand data ingestion and processing services

## AWS Analytics Services Overview

### Analytics Services Comparison

| Service | Type | Use Case | Cost Model |
|---------|------|----------|------------|
| **QuickSight** | BI Tool | Interactive dashboards, visualizations | Per user/per session |
| **Athena** | Query Service | Ad-hoc SQL queries on S3 | Per TB scanned |
| **Redshift** | Data Warehouse | Complex analytics, petabyte-scale | Per node hour |
| **EMR** | Big Data Processing | Hadoop/Spark workloads | Per instance hour |
| **Kinesis** | Streaming | Real-time data streaming | Per shard hour/data |
| **Glue** | ETL | Data catalog and ETL | Per DPU hour |
| **MSK** | Streaming | Managed Apache Kafka | Per broker hour |

---

## Amazon QuickSight

### Overview

**Amazon QuickSight** is a fully managed, serverless business intelligence (BI) service.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Serverless** | No infrastructure to manage |
| **Integration** | Connect to RDS, Redshift, S3, Athena, etc. |
| **ML Insights** | Anomaly detection, forecasting |
| **Embedding** | Embed dashboards in apps |
| **SPICE** | In-memory calculation engine |

### SPICE (Super-fast, Parallel, In-memory Calculation Engine)

**Purpose**: Super-fast performance for interactive dashboards.

**Capacity**:
- **Standard Edition**: 10 GB per user (up to 500 GB total)
- **Enterprise Edition**: 10 GB per user (up to 1 TB total)

**Benefits**:
- Sub-second response times
- Handles millions of rows
- Auto-scales capacity

### QuickSight Editions

| Edition | Price | Features |
|---------|-------|----------|
| **Standard** | $9/user/month | Basic BI, SPICE |
| **Enterprise** | $18/user/month | ML insights, embedding, AD integration |

### Use Cases

- **Executive Dashboards**: Business metrics visualization
- **Self-Service BI**: Business users create own analyses
- **Embedded Analytics**: Dashboards in applications
- **Anomaly Detection**: ML-powered outlier detection

---

## Amazon Athena

### Overview

**Amazon Athena** is an interactive query service that makes it easy to analyze data directly in Amazon S3 using standard SQL.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Serverless** | No infrastructure to provision |
| **S3 Queries** | Directly query data in S3 |
| **Standard SQL** | SQL based on Trino/Presto |
| **Pay-per-query** | $5 per TB of data scanned |

### Athena Features

**Supported Formats**:
- CSV, JSON, ORC, Avro, Parquet
- Logs (CloudTrail, VPC Flow Logs)
- Custom formats via SerDe

**Data Sources**:
- S3 (primary)
- CloudWatch Logs
- AWS Glue Data Catalog
- DynamoDB (via federated query)

**Cost Optimization**:
- **Partition data**: Reduce scanned data
- **Columnar formats**: Parquet, ORC (scan only needed columns)
- **Compression**: Reduce data size

### Athena vs Redshift

| Feature | Athena | Redshift |
|---------|--------|----------|
| **Type** | Serverless query | Data warehouse |
| **Setup** | None | Provision clusters |
| **Performance** | Slower (seconds to minutes) | Faster (sub-second to seconds) |
| **Concurrency** | Unlimited | Limited by WLM |
| **Use Case** | Ad-hoc queries, occasional analytics | Complex queries, high concurrency |

### Use Cases

- **Log Analysis**: CloudTrail, VPC Flow Logs, ELB logs
- **Ad-hoc Analysis**: Quick queries on S3 data
- **Data Discovery**: Explore data before building pipeline
- **Reporting**: Periodic reporting on S3 data

---

## Amazon Redshift

### Overview

**Amazon Redshift** is a fully managed, petabyte-scale data warehouse service.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Massively Parallel** | Distributed across nodes |
| **Columnar Storage** | Optimized for analytics |
| **Compression** | Reduces storage needs |
| **Scalable** | Scale compute and storage independently |

### Redshift Architecture

**Leader Node**:
- Receives queries
- Plans execution
- Aggregates results

**Compute Nodes**:
- Execute queries
- Store data
- Distributed across slices

**Node Types**:

| Type | Family | Use Case |
|------|--------|----------|
| **DC2** | Dense Compute | High performance, frequently accessed |
| **RA3** | Managed Storage | Separation of compute and storage |
| **DC1** | Legacy | Being replaced by RA3 |

### Redshift Features

**Concurrency Scaling**:
- Automatically add capacity
- Support nearly unlimited concurrent users
- Free for compatible workloads

**Materialized Views**:
- Pre-computed results
- Faster query performance
- Auto-refresh options

**Redshift Spectrum**:
- Query data directly in S3
- No data loading required
- Extends data warehouse to data lake

**Distribution Styles**:

| Style | Description | Use Case |
|-------|-------------|----------|
| **KEY** | Distributed on specific column | Joins on that column |
| **ALL** | Copy to all nodes | Small tables |
| **EVEN** | Round-robin distribution | Default |

### Use Cases

- **Data Warehousing**: Centralized analytics
- **Business Intelligence**: Power BI, Tableau, QuickSight
- **High-performance Analytics**: Complex queries
- **Data Lake Integration**: Redshift Spectrum

---

## Amazon Kinesis

### Overview

**Amazon Kinesis** makes it easy to collect, process, and analyze real-time, streaming data so you can get timely insights and react quickly to new information.

Kinesis is a collection of services for processing streams of various data. Data is processed in "shards" with each shard able to ingest 1000 records per second.

**Key Characteristics**:
- Transient data store (default retention of 24 hours, configurable up to 7 days)
- Default limit of 500 shards (can request increase to unlimited)
- Records consist of partition key, sequence number, and data blob (up to 1 MB)
- Synchronous replication across three AZs

### Kinesis Services

| Service | Purpose | Use Case |
|---------|---------|----------|
| **Kinesis Data Streams** | Real-time streaming | IoT, clickstreams, logs |
| **Kinesis Data Firehose** | Load streaming data | S3, Redshift, OpenSearch |
| **Kinesis Data Analytics** | Real-time SQL on streams | Anomaly detection, filtering |
| **Kinesis Video Streams** | Video streaming | Camera feeds, video analysis |

### Kinesis Data Streams

**Purpose**: Real-time processing of streaming big data.

**Key Characteristics**:
- Stores data for later processing (key difference from Firehose which delivers directly)
- Producers push data via Kinesis API, Producer Library (KPL), or Kinesis Agent
- Consumers process data in real time (EC2 instances, Lambda)
- Records accessible for 24 hours by default (can be extended to 7 days)

**Shards**:
- Base throughput unit of Kinesis Data Streams
- One shard provides 1 MB/sec data input and 2 MB/sec data output
- Each shard supports up to 1000 PUT records per second
- Stream is composed of one or more shards
- Total capacity = sum of capacities of all shards

**Resharding**:
- **Shard Split**: Divide single shard into two (increases capacity and cost)
- **Shard Merge**: Combine two shards into one (decreases capacity and cost)
- Adjust number of shards to adapt to data flow changes

**Pricing**:
- Shard Hour: On-demand capacity
- Data In/Out: Per GB
- Extended data retention (beyond 24 hours)

**Security**:
- KMS master keys for encryption
- IAM policies for access control
- HTTPS endpoints for encryption in flight
- VPC endpoints available

**Use Cases**:
- Real-time analytics
- IoT data ingestion
- Log and event data collection
- Clickstream tracking
- Accelerated log and data feed intake

### Kinesis Data Firehose

**Purpose**: Easiest way to load streaming data into data stores and analytics tools.

**Key Characteristics**:
- Serverless (no resources to manage, no capacity planning)
- Captures, transforms, and loads streaming data
- Near real-time analytics with existing BI tools
- Synchronous replication across three AZs during transport
- No shards, fully automated

**Destinations**:
- Amazon S3
- Amazon Redshift
- Amazon Elasticsearch Service (OpenSearch)
- Splunk

**Features**:
- Data transformation (Lambda)
- Data conversion (Parquet, ORC)
- Compression, encryption
- Batch processing
- Can back up source data to S3 before transformation

**Data Flow**:
- For S3: Delivers directly to bucket
- For Redshift: Delivers to S3 first, then issues COPY command to Redshift
- For Elasticsearch: Delivers to cluster, optionally backs up to S3
- For Splunk: Delivers to Splunk, optionally backs up to S3

**Record Size**: Maximum 1000 KB per record (before Base64-encoding)

**Use Cases**:
- Load streaming data to S3
- Real-time data lake ingestion
- Log aggregation
- ETL automation

### Kinesis Data Analytics

**Purpose**: Easiest way to process and analyze real-time streaming data.

**Key Characteristics**:
- Standard SQL queries to process Kinesis streams
- Real-time analysis
- Sits over Kinesis Data Streams and Kinesis Data Firehose
- Can ingest from both Streams and Firehose

**Application Components**:
- Input: Streaming source for application
- Application Code: SQL statements that process input and produce output
- Output: In-application streams for intermediate results

**Input Types**:
- Streaming data sources (continuously generated)
- Reference data sources (static data for enrichment)

**Destinations**:
- S3, Redshift, Elasticsearch
- Kinesis Data Streams

**Use Cases**:
- Time-series analytics
- Real-time dashboards
- Real-time alerts and notifications
- Anomaly detection

### Kinesis Video Streams

**Purpose**: Securely stream video from connected devices to AWS.

**Key Characteristics**:
- Durably stores, encrypts, and indexes video data streams
- Easy-to-use APIs for access
- Stores data for 24 hours by default (up to 7 days)
- Stores data in shards
- Encryption at rest with KMS

**Shard Capacity**:
- 5 transactions per second for reads
- Max read rate of 2 MB per second
- 1000 records per second for writes
- Max write of 1 MB per second

**Use Cases**:
- Camera feeds
- Video analysis
- Machine learning on video
- Security monitoring

### Kinesis Client Library (KCL)

**Purpose**: Java library that helps read records from Kinesis Stream with distributed applications.

**Key Differences**:
- KCL vs Kinesis Data Streams API:
  - Kinesis Data Streams API: Manage streams, resharding, putting/getting records
  - KCL: Abstraction specifically for processing data in consumer role

**KCL Functions**:
- Connects to stream and enumerates shards
- Coordinates shard associations with other workers
- Instantiates record processor for every shard
- Pulls data records and pushes to record processor
- Checkpoints processed records
- Balances shard-worker associations when instances change

**Scaling**:
- Each shard processed by exactly one KCL worker
- One worker can process multiple shards
- Number of instances should not exceed number of shards
- Progress checkpointed into DynamoDB (requires IAM access)

**Use Cases**:
- Distributed stream processing
- EC2, Elastic Beanstalk, on-premises servers

### Kinesis vs SQS vs SNS

| Feature | Kinesis | SQS | SNS |
|---------|---------|-----|-----|
| Data Model | Pull | Pull | Push |
| Data Persistence | Up to 7 days | Deleted after consumed | Not persisted |
| Throughput | Must provision shards | No provisioning needed | No provisioning needed |
| Ordering | Shard-level ordering | FIFO queues only | No ordering |
| Consumers | As many as needed | As many as needed | Up to 10M subscribers |
| Use Case | Real-time big data, ETL | Decoupling, buffering | Fan-out, notifications |

---

## AWS Glue

### Overview

**AWS Glue** is a serverless data integration service that makes it easy to discover, prepare, and combine data.

### Glue Components

| Component | Purpose |
|-----------|---------|
| **Data Catalog** | Central metadata repository |
| **Crawlers** | Discover data and populate catalog |
| **ETL Jobs** | Transform and move data |
| **Jobs** | Spark or Python scripts |
| **Triggers** | Schedule ETL jobs |
| **Workflows** | Orchestrate multiple jobs |

### Glue Data Catalog

**Purpose**: Central metadata repository for data assets.

**Features**:
- Tables, schemas, partitions
- Integration with Athena, Redshift Spectrum, EMR
- Column-level statistics

### Use Cases

- **Data Discovery**: Catalog data across S3
- **ETL Pipelines**: Transform data for analytics
- **Data Lake**: Build and maintain data lake
- **Schema Evolution**: Handle schema changes

---

## Amazon EMR (Elastic MapReduce)

### Overview

**Amazon EMR** is a managed cluster platform that simplifies running big data frameworks.

### Supported Applications

| Application | Type | Use Case |
|-------------|------|----------|
| **Apache Spark** | In-memory processing | ETL, machine learning, graph processing |
| **Hadoop MapReduce** | Batch processing | Big data processing |
| **Presto** | Distributed SQL | Interactive queries |
| **Hive** | Data warehouse | SQL on Hadoop |
| **HBase** | NoSQL database | Real-time read/write |
| **Flink** | Stream processing | Real-time analytics |

### EMR Use Cases

- **Big Data Processing**: Large-scale data processing
- **Machine Learning**: Spark MLlib
- **Data Transformation**: ETL at scale
- **Log Processing**: Web logs, sensor data

---

## MSK (Managed Streaming for Kafka)

### Overview

**Amazon MSK** is a fully managed Apache Kafka service.

### Key Features

| Feature | Description |
|---------|-------------|
| **Managed** | AWS handles provisioning, patching |
| **Highly Available** | Multi-AZ deployment |
| **Compatible** | Native Kafka APIs |
| **Secure** | IAM authentication, encryption |

### Use Cases

- **Event Streaming**: Real-time event processing
- **Data Pipelines**: Stream processing
- **Log Aggregation**: Centralized logging
- **Microservices**: Event-driven architecture

---

## Exam Tips - Analytics Services

### High-Yield Topics

1. **QuickSight**:
   - Serverless BI tool
   - SPICE = in-memory engine
   - ML insights = anomaly detection, forecasting

2. **Athena**:
   - Serverless SQL queries on S3
   - Pay per TB scanned ($5/TB)
   - Use partitions, columnar formats to reduce cost

3. **Redshift**:
   - Petabyte-scale data warehouse
   - Columnar storage, massively parallel
   - RA3 = managed storage (separate compute/storage)
   - Spectrum = query S3 data

4. **Kinesis**:
   - Data Streams = real-time streaming, stores data (24h-7d), 1 MB/s input, 2 MB/s output per shard
   - Firehose = serverless loading to S3/Redshift/OpenSearch, no shards
   - Analytics = SQL on streams, real-time processing
   - Video = video streaming for camera feeds
   - KCL = Java library for distributed stream processing

5. **Glue**:
   - Data Catalog = metadata repository
   - ETL = serverless data transformation
   - Crawlers = discover data

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Analytics Services Cheat Sheet](https://digitalcloud.training/aws-analytics-services/) - Comprehensive analytics services reference
- [Amazon Kinesis Cheat Sheet](https://digitalcloud.training/amazon-kinesis/) - Detailed Kinesis guide for exam preparation

### Official AWS Documentation
- [Amazon QuickSight Documentation](https://docs.aws.amazon.com/quicksight/)
- [Amazon Athena Documentation](https://docs.aws.amazon.com/athena/)
- [Amazon Redshift Documentation](https://docs.aws.amazon.com/redshift/)
- [Amazon Kinesis Documentation](https://docs.aws.amazon.com/kinesis/)
- [AWS Skill Builder](https://skillbuilder.aws/) - Free analytics courses and certification prep
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on analytics labs and practice environments
- [AWS Analytics Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive analytics learning paths

### AWS Analytics Resources
- [QuickSight Pricing](https://aws.amazon.com/quicksight/pricing/) - BI pricing
- [Athena Pricing](https://aws.amazon.com/athena/pricing/) - Serverless query pricing
- [Redshift Pricing](https://aws.amazon.com/redshift/pricing/) - Data warehouse pricing
- [Kinesis Pricing](https://aws.amazon.com/kinesis/pricing/) - Streaming data pricing

---

**Next**: [AI/ML Services](ai-ml-services.md)
