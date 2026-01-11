# Domain 3: Networking Services

**CLF-C02 Exam Domain 3 - Part 4 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- **Define the AWS global infrastructure** (Domain 3, Task 3.2)
- Understand Amazon VPC components and architecture
- Configure public and private subnets
- Understand VPC networking features
- Compare Route 53 routing policies
- Identify AWS networking services for different use cases

---

## AWS Global Infrastructure

**Domain 3, Task 3.2: Define the AWS global infrastructure**

### Overview

The AWS global infrastructure is built around Regions and Availability Zones, providing a reliable, secure, and high-performance environment for running applications.

### Components Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Global Infrastructure                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  34+ Geographic Regions                                     │
│    └── 108+ Availability Zones                              │
│         └── 600+ Edge Locations                             │
│              └── 13 Regional Edge Caches                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. AWS Regions

**Definition**: A geographic area where AWS has multiple, isolated data centers.

**Key Points**:
- 34+ regions worldwide (US, EU, AP, etc.)
- Each region is completely independent
- Data residency and compliance requirements
- Latency considerations for users
- Connected through high-bandwidth, low-latency networking

**Common Regions**:
| Region Code | Location |
|-------------|----------|
| `us-east-1` | N. Virginia |
| `us-west-2` | Oregon |
| `eu-west-1` | Ireland |
| `eu-central-1` | Frankfurt |
| `ap-southeast-1` | Singapore |
| `ap-northeast-1` | Tokyo |

**Use Cases for Multiple Regions**:
- **Disaster Recovery**: Deploy applications in multiple regions for business continuity
- **Low Latency**: Serve end users in different geographic locations
- **Data Sovereignty**: Meet data residency requirements by storing data in specific countries
- **Compliance**: Satisfy regulatory requirements for data location

### 2. Availability Zones (AZs)

**Definition**: One or more discrete data centers within an AWS Region.

**Key Characteristics**:
- Each AZ is isolated from failures in other AZs
- Connected with low-latency, high-bandwidth networking (within region)
- Power, networking, and connectivity are independent
- **No single point of failure** across AZs
- **Best Practice**: Distribute applications across multiple AZs for high availability

**Architecture**:
```
┌─────────────────────────────────────┐
│         AWS Region (us-east-1)      │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────┐  ┌─────────┐  ┌──────┐ │
│  │   AZ1   │  │   AZ2   │  │ AZ3  │ │
│  │ Data    │  │ Data    │  │ Data │ │
│  │ Center  │  │ Center  │  │      │ │
│  └─────────┘  └─────────┘  └──────┘ │
│      │            │            │    │
│      └────────────┴────────────┘    │
│         Low Latency Network         │
└─────────────────────────────────────┘
```

**Achieving High Availability**:
- Use multiple AZs for redundancy
- If one AZ fails, traffic fails over to another AZ
- **Load Balancers** distribute traffic across AZs
- **Multi-AZ RDS** automatically replicates to another AZ

### 3. Edge Locations

**Definition**: Sites that CloudFront uses to cache content closer to end users.

**Purpose**:
- Content delivery via CloudFront (CDN)
- Lower latency for end users
- 600+ locations worldwide
- Reduce load on origin servers

**Use Cases**:
- Static content delivery (images, videos, CSS, JS)
- Dynamic content delivery with Lambda@Edge
- Live and on-demand video streaming
- API acceleration

### 4. Regional Edge Caches

**Purpose**:
- Sit between CloudFront edge locations and AWS Region
- Cache content for longer periods
- Reduce origin load for popular content
- Improve cache hit rates

**How It Works**:
```
User → Edge Location (miss) → Regional Edge Cache → Origin
```

### 5. AWS Local Zones

**Purpose**:
- Place compute, storage, database, and other services
- Closer to large population, industry, and IT centers
- Low-latency applications (5-10ms latency)

**Use Cases**:
- Real-time gaming
- Media rendering
- Machine learning inference at the edge
- Healthcare applications requiring low latency

### 6. AWS Wavelength

**Purpose**:
- Deploy AWS services at the edge of 5G networks
- Ultra-low latency applications (1-2ms)
- For ML inference, gaming, IoT

**Use Cases**:
- Connected vehicles
- Industrial automation
- Live event streaming
- Augmented reality (AR) and virtual reality (VR)

### Relationships Between Components

| Component | Description | Relationship |
|-----------|-------------|--------------|
| **Regions** | Geographic areas | Contains multiple AZs, independent from each other |
| **AZs** | Isolated data centers | Within regions, connected by low-latency network |
| **Edge Locations** | CDN caching points | Globally distributed, cache content from regions |
| **Regional Edge Caches** | Intermediate caching | Between edge locations and regions |
| **Local Zones** | Extension of regions | Located near metropolitan areas |
| **Wavelength Zones** | 5G edge infrastructure | Located at carrier edge locations |

### High Availability Strategies

| Strategy | Description | Component |
|----------|-------------|-----------|
| **Multi-AZ** | Distribute resources across AZs | Within a single region |
| **Multi-Region** | Deploy resources across regions | Across geographic regions |
| **Cross-Zone Load Balancing** | Distribute traffic across AZs | ELB feature (enabled by default) |
| **Global Accelerator** | Improve availability and performance | Uses AWS global network |

---

## Amazon VPC (Virtual Private Cloud)

### Overview

**Amazon VPC** enables you to launch AWS resources into a virtual network that you define.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Isolated Network** | Your own private cloud |
| **CIDR Block** | Define IP address range |
| **Subnets** | Segments of IP addresses |
| **Multiple AZs** | Distribute across availability zones |
| **Hybrid Connectivity** | Connect to on-premises via VPN/Direct Connect |

### VPC Components

#### 1. VPC Basics

**CIDR Block**:
- IPv4: Example `10.0.0.0/16` (65,536 addresses)
- IPv6: Optional, can be associated
- **Smallest**: `/28` (16 addresses)
- **Largest**: `/16` (65,536 addresses)

**Reserved IPs** (5 per subnet):
- `10.0.0.0`: Network address
- `10.0.0.1`: VPC router
- `10.0.0.2`: DNS server
- `10.0.0.3`: Future use
- `10.0.0.255`: Network broadcast

#### 2. Subnets

**Definition**: A segment of a VPC's IP address range.

**Types**:

| Type | Description | Internet Access |
|------|-------------|-----------------|
| **Public Subnet** | Has route to Internet Gateway | Yes |
| **Private Subnet** | No direct route to internet | No (via NAT only) |

**Subnet Sizing**:
- `/24`: 256 IPs (251 usable after AWS reserves 5)
- `/26`: 64 IPs
- `/28`: 16 IPs

**1 subnet = 1 AZ** (A subnet is tied to a specific AZ)

#### 3. Internet Gateway (IGW)

**Purpose**: Allows communication between resources in VPC and internet.

**Characteristics**:
- **Horizontally scaled**, redundant, highly available
- **One per VPC** (can have multiple, but not recommended)
- Required for public subnets
- **Two-way communication**: VPC ↔ Internet

#### 4. NAT Gateway (NAT)

**Purpose**: Allows instances in private subnets to connect to internet, but prevents internet from initiating connections.

**Characteristics**:
- **Created in public subnet**
- **Elastic IP** required
- **Scaled automatically** (up to 45 Gbps)
- **AZ-specific** (create NAT in each AZ for HA)
- **One-way communication**: Private subnet → Internet

**NAT Gateway vs NAT Instance**:
| Feature | NAT Gateway | NAT Instance |
|---------|-------------|--------------|
| **Scalability** | Automatic | Manual |
| **Availability** | Highly available | Single point of failure |
| **Management** | AWS-managed | Self-managed |
| **Bandwidth** | Up to 45 Gbps | Limited by instance |

#### 5. Route Tables

**Purpose**: Routes network traffic between subnets and internet gateways.

**Components**:
- **Routes**: Rules for where to send traffic
- **Associations**: Which subnets use the route table

**Example Route Table**:
```
Destination      Target
10.0.0.0/16  →  Local
0.0.0.0/0    →  igw-12345 (Internet Gateway)
```

**Main vs Custom Route Tables**:
- **Main**: Default route table, automatically associated with new subnets
- **Custom**: Created by you, explicitly associated with subnets

#### 6. Security Groups vs NACLs

| Feature | Security Group | NACL |
|---------|---------------|------|
| **Scope** | Instance level | Subnet level |
| **State** | Stateful | Stateless |
| **Rules** | Allow only | Allow and Deny |
| **Evaluation** | All rules | Numbered order |
| **Default** | Allow all outbound | Allow all |

**Security Group**:
- Virtual firewall at instance level
- **Stateful**: Return traffic automatically allowed
- **Allow rules only** (no deny)
- **Best Practice**: Use security groups for most security needs

**NACL (Network Access Control List)**:
- Stateless firewall at subnet level
- **Stateless**: Return traffic must be explicitly allowed
- **Ordered rules** (1-32766)
- **Use Case**: Rarely needed, for specific subnet-level controls

#### 7. VPC Peering

**Purpose**: Connect two VPCs privately.

**Characteristics**:
- **One-to-one relationship** (cannot transit)
- **Same region** (standard) or **different regions** (inter-region)
- **No single point of failure**
- **Bandwidth**: Same as within VPC

**Limitations**:
- **No transitive peering**: A-B, B-C ≠ A-C
- **Cannot have overlapping CIDRs**

#### 8. VPC Endpoints

**Purpose**: Private connection to AWS services without internet gateway.

**Types**:

| Type | Description | Use Case |
|------|-------------|----------|
| **Interface Endpoint** | ENIs in subnet, private IPs | S3, DynamoDB, etc. |
| **Gateway Endpoint** | VPC component, target in route table | S3, DynamoDB |

**Gateway Endpoint Example**:
```
Route Table:
Destination      Target
10.0.0.0/16  →  Local
0.0.0.0/0    →  igw-12345
s3.amazonaws.com → vpce-12345 (Gateway Endpoint)
```

**Benefits**:
- No internet gateway required
- No data transfer charges
- Private connectivity

---

## AWS Direct Connect

### Overview

**AWS Direct Connect** establishes a dedicated network connection from your premises to AWS.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Dedicated Connection** | Bypasses internet |
| **Lower Latency** | More consistent network experience |
| **Higher Bandwidth** | Up to 100 Gbps |
| **Cost** | Connection fee + data transfer |

### Direct Connect vs VPN

| Feature | Direct Connect | VPN |
|---------|---------------|-----|
| **Connection** | Dedicated physical | Over internet |
| **Encryption** | Optional (you manage) | Built-in (IPsec) |
| **Latency** | Lower, consistent | Variable |
| **Cost** | Higher | Lower |
| **Setup Time** | Weeks | Minutes |
| **Use Case** | Large data transfer, compliance | Remote access, smaller scale |

---

## Amazon Route 53

### Overview

**Amazon Route 53** is a highly available and scalable Domain Name System (DNS) web service.

### Key Features

| Feature | Description |
|---------|-------------|
| **Domain Registration** | Register domain names |
| **DNS Hosting** | Manage DNS records |
| **Health Checks** | Monitor endpoint health |
| **Routing Policies** | Control traffic routing |
| **99.99% SLA** | Availability guarantee |

### DNS Records

**Common Record Types**:

| Type | Description | Example |
|------|-------------|---------|
| **A** | IPv4 address | `1.2.3.4` |
| **AAAA** | IPv6 address | `2001:0db8::1` |
| **CNAME** | Alias to another name | `www.example.com` |
| **Alias** | AWS resource alias (Route 53 specific) | S3 bucket, CloudFront |

**Alias vs CNAME**:
- **Alias**: Route 53 specific, free, can point to AWS resources (S3, CloudFront, ELB)
- **CNAME**: Standard DNS, not allowed for root domain, points to any DNS name

### Routing Policies

| Policy | Description | Use Case |
|--------|-------------|----------|
| **Simple** | Single resource | Single resource serving all traffic |
| **Weighted** | Distribute by percentage | A/B testing, gradual rollout |
| **Latency** | Lowest latency | Global applications |
| **Failover** | Active/passive | Disaster recovery |
| **Geolocation** | Based on user location | Localized content |
| **Geoproximity** | Bias resources to locations | Traffic steering |
| **Multivalue Answer** | Multiple records | DNS-level load balancing |
| **IP-based** | Based on client IP subnet | Unicast routing |

**Examples**:

**Simple Routing**:
```
example.com → 192.0.2.1 (single IP)
```

**Weighted Routing**:
```
example.com → 192.0.2.1 (weight 10)  → 10% traffic
           → 192.0.2.2 (weight 90)  → 90% traffic
```

**Latency Routing**:
```
example.com → US East (if fastest)
           → US West (if fastest)
           → EU (if fastest)
```

**Failover Routing**:
```
example.com → Primary (healthy)
           → Secondary (if primary unhealthy)
```

---

## AWS CloudFront

### Overview

**Amazon CloudFront** is a fast content delivery network (CDN) service.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Global Edge Network** | 600+ edge locations worldwide |
| **Caching** | Content cached closer to users |
| **DDoS Protection** | AWS Shield Standard (free) |
| **Custom SSL** | Using AWS Certificate Manager |
| **Origin** | S3, EC2, ELB, or external server |

### CloudFront Components

**Distributions**:
- **Web Distribution**: Websites, APIs
- **RTMP Distribution**: Media streaming (legacy)

**Origins**:
- **S3 Bucket**: Static content
- **EC2 Instance**: Custom origin
- **ELB**: Load balanced applications
- **MediaPackage**: Video streaming

**Behaviors**:
- **Path Pattern**: Which requests go to which origin
- **Cached Methods**: GET, HEAD (default)
- **TTL**: Time-to-live for cache
- **Compressed**: Auto-compress files

### CloudFront Pricing

**Pricing Components**:
- **Data Transfer Out**: Per GB to internet
- **Requests**: Per 10,000 requests
- **Regional**: Varies by edge location

---

## Other Networking Services

### 1. AWS PrivateLink

**Purpose**: Expose services privately to other VPCs.

**Use Cases**:
- Expose SaaS services privately
- Connect to partner services
- Hybrid cloud connectivity

### 2. AWS Transit Gateway

**Purpose**: Hub-and-spoke model for connecting VPCs and on-premises networks.

**Benefits**:
- Simplify network topology
- Single point of control
- Transitive routing (unlike VPC peering)

**Architecture**:
```
         Transit Gateway (Hub)
              /     |     \
          VPC A   VPC B   VPC C
```

### 3. Elastic Load Balancing (ELB)

**Overview**: Distributes incoming traffic across multiple targets.

**Types**:

| Type | Layer | Use Case |
|------|-------|----------|
| **Application Load Balancer** | Layer 7 | HTTP/HTTPS traffic, content-based routing |
| **Network Load Balancer** | Layer 4 | TCP, UDP, TLS, ultra-low latency |
| **Gateway Load Balancer** | Layer 3 | Virtual appliances (firewalls, IDS) |
| **Classic Load Balancer** | Layer 4/7 | Legacy (deprecated for new use) |

**Application Load Balancer Features**:
- Content-based routing (path-based, host-based)
- WebSockets support
- HTTP/2 support
- Integration with WAF, Shield

**Network Load Balancer Features**:
- Ultra-low latency
- Static IP addresses
- Preserves source IP
- TLS termination

**Cross-Zone Load Balancing**:
- Distributes traffic across AZs
- Enabled by default (ALB, NLB)
- Can be disabled (NLB only)

---

## Exam Tips - Networking Services

### High-Yield Topics

1. **AWS Global Infrastructure**:
   - **Regions** = Geographic areas with multiple AZs, independent from each other
   - **AZs** = Isolated data centers within regions, no single point of failure
   - **Edge Locations** = CDN caching points for CloudFront
   - **Local Zones** = Near metropolitan areas (5-10ms latency)
   - **Wavelength Zones** = At 5G edge (1-2ms latency)
   - **Multi-AZ** = High availability within a region
   - **Multi-Region** = Disaster recovery across geographic areas

2. **VPC Components**:
   - Internet Gateway = Public internet access (two-way)
   - NAT Gateway = Private subnet outbound access (one-way)
   - Route Tables = Control traffic flow
   - Security Groups = Instance-level, stateful
   - NACLs = Subnet-level, stateless

3. **Public vs Private Subnet**:
   - Public = Route to IGW
   - Private = No IGW route (uses NAT)

4. **VPC Peering**:
   - One-to-one only
   - Cannot transit (A-B, B-C ≠ A-C)
   - Cannot have overlapping CIDRs

5. **Route 53 Routing Policies**:
   - Simple = Single resource
   - Weighted = Percentage distribution
   - Latency = Lowest latency
   - Failover = Active/passive

6. **CloudFront**:
   - CDN with 600+ edge locations
   - Caches content closer to users
   - Supports multiple origins

7. **Direct Connect vs VPN**:
   - Direct Connect = Dedicated, lower latency, higher cost
   - VPN = Over internet, higher latency, lower cost

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Global Infrastructure Cheat Sheet](https://digitalcloud.training/aws-global-infrastructure/) - Detailed infrastructure guide for exam preparation
- [AWS Networking Services Cheat Sheet](https://digitalcloud.training/aws-networking-services/) - Comprehensive networking services reference for exam prep

### Official AWS Documentation
- [Amazon VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Amazon Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [Amazon CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/)
- [AWS Skill Builder](https://skillbuilder.aws/) - Free networking courses and certification prep
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on networking labs and practice environments
- [AWS Networking Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive networking learning paths

### AWS Networking Resources
- [VPC Pricing](https://aws.amazon.com/vpc/pricing/) - Current networking pricing
- [Route 53 Pricing](https://aws.amazon.com/route53/pricing/) - DNS service pricing
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/) - CDN pricing
- [Direct Connect Pricing](https://aws.amazon.com/directconnect/pricing/) - Dedicated network connection pricing

---

**Next**: [Analytics Services](analytics-services.md)
