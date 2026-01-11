# Domain 2: Security and Compliance

**CLF-C02 Exam Domain 2 | 30% of Scored Content**

## Learning Objectives

By the end of this domain, you will be able to:

- Understand the AWS Shared Responsibility Model
- Define AWS security concepts and services
- Understand IAM components and policies
- Identify AWS security services for different use cases
- Understand compliance concepts

## AWS Shared Responsibility Model

### Overview

The AWS Shared Responsibility Model defines which security tasks are AWS's responsibility and which are the customer's responsibility.

### Visual Model

```
┌─────────────────────────────────────────────────────────────┐
│              AWS Shared Responsibility Model                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  AWS RESPONSIBILITY                CUSTOMER RESPONSIBILITY  │
│  ┌──────────────────┐              ┌──────────────────┐     │
│  │ Security OF      │              │ Security IN      │     │
│  │ the Cloud        │              │ the Cloud        │     │
│  ├──────────────────┤              ├──────────────────┤     │
│  │ • Physical       │              │ • IAM & Access   │     │
│  │   Controls       │              │ • Data           │     │
│  │ • Hardware       │              │ • Encryption     │     │
│  │ • Networking     │              │ • Network Config │     │
│  │ • Software       │              │ • OS Patching    │     │
│  │ (Hypervisor)     │              │ • App Security   │     │
│  └──────────────────┘              └──────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Responsibilities by Service Model

| Service Model | AWS Responsibility | Customer Responsibility |
|---------------|-------------------|------------------------|
| **IaaS** (EC2) | Physical security, network, hypervisor | OS, apps, data, IAM |
| **PaaS** (RDS) | All of IaaS + OS, database software | Data, IAM, database configuration |
| **SaaS** (WorkSpaces) | Most security tasks | User access, data classification |

### Security OF the Cloud (AWS)

**AWS is responsible for**:

| Component | Description |
|-----------|-------------|
| **Physical Security** | Data center access, security guards, cameras |
| **Hardware** | Servers, storage devices, networking equipment |
| **Networking** | Network infrastructure, firewalls |
| **Virtualization** | Hypervisor that isolates customer instances |
| **Regions & AZs** | Availability and durability |
| **Edge Locations** | Physical security of CDN infrastructure |

### Security IN the Cloud (Customer)

**Customer is responsible for**:

| Component | Description |
|-----------|-------------|
| **IAM** | User management, access control, permissions |
| **Data** | Classification, encryption, backup |
| **Network** | VPC configuration, security groups, NACLs |
| **Operating System** | Patching, hardening, anti-virus |
| **Applications** | Code security, dependencies, vulnerabilities |
| **Configuration** | Security settings, compliance |

### Key Principle

> **"AWS is responsible for security OF the cloud, you are responsible for security IN the cloud."**

---

## Identity and Access Management (IAM)

### Overview

**IAM** is the service that controls access to AWS resources securely.

### Core Components

#### 1. IAM Users

**Definition**: An entity that represents a person or application that interacts with AWS.

**Characteristics**:
- Long-term credentials (password, access keys)
- Can have console access and/or programmatic access
- Belong to one or more groups

**Example**:
```bash
# AWS CLI command to create a user
aws iam create-user --user-name john-developer
```

#### 2. IAM Groups

**Definition**: A collection of IAM users.

**Benefits**:
- Attach permissions to groups, not individual users
- Users inherit permissions from groups
- Simplifies permission management

**Best Practice**: Always use groups for permissions, assign users to groups.

**Example**:
```bash
# Create a group
aws iam create-group --group-name Developers

# Add user to group
aws iam add-user-to-group --group-name Developers --user-name john-developer
```

#### 3. IAM Roles

**Definition**: An IAM identity with specific permissions that is not associated with a specific user or group.

**Use Cases**:
- Applications running on EC2 need AWS permissions
- Cross-account access
- Federated access (corporate SSO)
- AWS Service roles (e.g., Lambda needs to access S3)

**Key Difference from Users**:
- Roles provide **temporary credentials**
- Users have **long-term credentials**

**Example**: EC2 instance using a role to access S3
```
┌──────────────┐         Assume Role          ┌──────────────┐
│   EC2        │ ────────────────────────────▶│    S3        │
│  Instance    │      (Temporary Creds)       │   Bucket     │
└──────────────┘                               └──────────────┘
       │
       └── Instance Profile (contains role)
```

#### 4. IAM Policies

**Definition**: JSON documents that define permissions.

**Policy Structure**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

**Policy Elements**:

| Element | Description | Values |
|---------|-------------|--------|
| **Effect** | Allow or Deny | Allow, Deny |
| **Action** | Specific AWS operations | `"s3:GetObject"`, `"ec2:RunInstances"` |
| **Resource** | AWS resource ARN | `"arn:aws:s3:::bucket/*"` |
| **Condition** | When policy applies | `"IpAddress": {"aws:SourceIp": "1.2.3.4/32"}` |

**Policy Types**:

| Type | Description | Example |
|------|-------------|---------|
| **Identity-based** | Attached to users, groups, roles | AdministratorAccess |
| **Resource-based** | Attached to resources | S3 Bucket Policy |
| **Trust policies** | Who can assume a role | IAM Role Trust Policy |
| **Permissions boundary** | Maximum permissions for an entity | DeveloperBoundary |

#### 5. IAM Best Practices

1. **Root Account**: Use MFA, lock away access keys, only for account admin
2. **Individual Users**: Never share credentials, one user per person
3. **Groups**: Use groups for permissions, assign users to groups
4. **Least Privilege**: Grant only minimum required permissions
5. **Roles**: Use roles for applications and cross-account access
6. **MFA**: Enable for all users, especially privileged accounts
7. **Rotate Credentials**: Regularly rotate passwords and access keys
8. **Remove Unused**: Delete unused users, groups, roles, and policies

---

## IAM Policies Deep Dive

### Policy Evaluation Logic

```
Request → Default Deny → Explicit Allow? → Explicit Deny?
           (All start)    (Check)          (Overrides all)
              │              │                 │
              ▼              ▼                 ▼
           DENIED     ALLOWED if no      ALWAYS DENIED
                      explicit deny
```

**Key Rules**:
1. **Default Deny**: All requests are denied by default
2. **Explicit Deny**: Overrides any Allow
3. **Explicit Allow**: Grants permission (if no Deny)

### Common Managed Policies

**AWS Managed Policies**:
- `AdministratorAccess` - Full access to all AWS services
- `PowerUserAccess` - Full access except IAM
- `ReadOnlyAccess` - Read-only access to all services
- `AmazonS3FullAccess` - Full access to S3

### Example Policies

**Read-Only S3 Access**:
```json
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
```

**S3 Bucket Access (Specific Bucket)**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::my-app-bucket/*"
    }
  ]
}
```

**EC2 Full Access**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
```

---

## AWS Security Services

### Overview

AWS provides a comprehensive set of security services to help protect your data, applications, and infrastructure.

### Security Services Comparison

| Service | Type | Purpose | Use Case |
|---------|------|---------|----------|
| **IAM** | Identity | Access management | User/role permissions |
| **KMS** | Encryption | Key management | Encrypt data at rest |
| **Secrets Manager** | Secrets | Store secrets | Database credentials |
| **Shield** | DDoS | DDoS protection | Layer 3/4/7 protection |
| **WAF** | Firewall | Web application firewall | HTTP(S) protection |
| **GuardDuty** | Threat detection | Intelligent threat detection | Security monitoring |
| **Security Hub** | Compliance | Security and compliance center | Centralized security |
| **Inspector** | Vulnerability | Automated security assessments | EC2 vulnerability scan |
| **Macie** | Data discovery | Data classification and protection | S3 sensitive data |
| **CloudHSM** | Encryption | Hardware security module | FIPS 140-2 compliance |
| **ACM** | Certificates | SSL/TLS certificate management | Certificate provisioning |

### Detailed Service Coverage

#### 1. AWS KMS (Key Management Service)

**Purpose**: Managed service that makes it easy to create and control encryption keys.

**Features**:
- Centralized key management
- Hardware Security Modules (HSMs)
- Key rotation
- IAM integration
- Audit logging via CloudTrail

**Use Cases**:
- Encrypt EBS volumes
- Encrypt S3 objects
- Encrypt RDS instances
- Encrypt Lambda environment variables

**Key Concepts**:
- **Customer Master Keys (CMKs)**: Main encryption keys
- **Data Keys**: Generated by CMKs to encrypt data
- **Envelope Encryption**: CMK encrypts data keys, data keys encrypt data

#### 2. AWS Shield

**Purpose**: Managed DDoS protection service.

**Tiers**:

| Tier | Cost | Protection |
|------|------|------------|
| **Standard** | FREE | Automatic protection for all AWS customers |
| **Advanced** | $3,000/month + usage | Advanced protection, 24/7 access, DDoS Response Team (DRT) |

**Protection Against**:
- Network layer (Layer 3/4) attacks: SYN floods, UDP reflection
- Application layer (Layer 7) attacks: HTTP GET floods, DNS query floods

#### 3. AWS WAF (Web Application Firewall)

**Purpose**: Web application firewall that helps protect web applications.

**Features**:
- Rule-based traffic filtering
- Bot control
- SQL injection protection
- Cross-site scripting (XSS) protection
- Rate-based rules

**Components**:
- **WebACL**: Container for rules
- **Rules**: Conditions for allowing/blocking requests
- **Rule Groups**: Collections of rules

**Pricing**: Pay per web ACL, per rule, and per million requests

#### 4. Amazon GuardDuty

**Purpose**: Intelligent threat detection service.

**Capabilities**:
- Analyzes logs (VPC Flow Logs, CloudTrail, DNS logs)
- Machine learning for anomaly detection
- Threat intelligence feeds
- Integrated findings with Security Hub

**Findings Categories**:
- CryptoCurrency (unusual activity)
- Backdoor (Trojan detected)
- Behavior (unusual API calls)
- Reconnaissance (port scanning)
- Stealth (attempting to avoid detection)

#### 5. AWS Security Hub

**Purpose**: Comprehensive security and compliance center.

**Features**:
- Aggregates security alerts and findings
- Automates security checks
- Tracks compliance with standards (CIS, NIST, PCI DSS)
- Centralized security management

**Integrations**: GuardDuty, Inspector, Macie, IAM Access Analyzer

#### 6. AWS Inspector

**Purpose**: Automated security assessment service.

**What It Scans**:
- EC2 instances
- Lambda functions
- Container images (ECR)

**Vulnerability Checks**:
- Common Vulnerabilities and Exposures (CVEs)
- Network reachability
- Security best practices

#### 7. AWS Secrets Manager

**Purpose**: Securely store, encrypt, and manage secrets.

**Features**:
- Rotate secrets automatically
- Encrypt with KMS
- Audit secret access via CloudTrail
- Integrate with RDS, DocumentDB, Redshift

**Secret Types**:
- Database credentials
- API keys
- OAuth tokens
- Certificates

#### 8. Amazon Macie

**Purpose**: Fully managed data security and data privacy service.

**Capabilities**:
- Machine learning to discover sensitive data
- Classifies PII, PHI, financial data
- Alerts on suspicious access to S3 data
- Provides data inventory

**Use Cases**:
- GDPR compliance
- HIPAA compliance
- Data loss prevention

#### 9. AWS CloudHSM

**Purpose**: Hardware Security Module (HSM) for key management.

**Difference from KMS**:
- **KMS**: Managed, multi-tenant, simpler
- **CloudHSM**: Dedicated, single-tenant, FIPS 140-2 Level 3 validated

**Use Cases**:
- Strong regulatory compliance requirements
- Need for exclusive control of cryptographic keys
- Exportable keys

#### 10. AWS Certificate Manager (ACM)

**Purpose**: Provision and manage SSL/TLS certificates.

**Features**:
- Free public certificates
- Automatic certificate renewal
- Integration with:
  - Elastic Load Balancing
  - CloudFront
  - API Gateway

---

## Compliance and Governance

### Compliance Programs

**AWS supports many compliance certifications**:

| Standard | Industry | Focus |
|----------|----------|-------|
| **SOC 1/2/3** | General | Service organization controls |
| **PCI DSS** | Payments | Payment card security |
| **HIPAA** | Healthcare | Protected health information |
| **FedRAMP** | Government | Federal risk management |
| **ISO 27001** | General | Information security |
| **GDPR** | Privacy | EU data protection |
| **NIST** | Government | Security framework |

### AWS Artifact

**Purpose**: Portal for accessing AWS security and compliance documentation.

**Contains**:
- Audit reports (SOC, PCI, ISO)
- Agreements (BAA, NDA)
- Compliance guides

### AWS Config

**Purpose**: Service that enables auditing, evaluating, and recording configurations.

**Features**:
- Track resource inventory
- Assess compliance with rules
- Detect configuration changes
- Remediate non-compliant resources

---

## Exam Tips - Domain 2

### High-Yield Topics

1. **Shared Responsibility Model**: Most important concept!
   - AWS = Security OF the cloud (physical, hardware, networking)
   - Customer = Security IN the cloud (IAM, data, OS, apps)

2. **IAM Components**:
   - Users = People/applications with long-term credentials
   - Groups = Collection of users for permissions
   - Roles = Temporary credentials for services/apps
   - Policies = JSON permission documents

3. **IAM Policy Evaluation**: Default DENY → Explicit ALLOW → Explicit DENY (trumps all)

4. **MFA**: Multi-Factor Authentication - strongly recommended for root account

5. **Security Services**:
   - **KMS**: Encryption key management
   - **Shield**: DDoS protection (Standard free, Advanced paid)
   - **WAF**: Web application firewall (Layer 7)
   - **GuardDuty**: Threat detection
   - **Secrets Manager**: Secret storage and rotation
   - **Inspector**: Vulnerability scanning

6. **Encryption**:
   - At rest: KMS, CloudHSM
   - In transit: TLS/SSL, ACM
   - Client-side: Encrypt before upload

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Security Services Cheat Sheet](https://digitalcloud.training/aws-security-services/) - Comprehensive security services reference for exam prep
- [AWS Identity and Access Management Cheat Sheet](https://digitalcloud.training/aws-identity-and-access-management/) - Detailed IAM guide for exam preparation
- [AWS Shared Responsibility Model Cheat Sheet](https://digitalcloud.training/aws-shared-responsibility-model/) - Security responsibilities reference

### Official AWS Documentation
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [AWS Security Services](https://aws.amazon.com/security/)
- [AWS Compliance Programs](https://aws.amazon.com/compliance/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/whitepapers/latest/security-best-practices/)
- [AWS Skill Builder Security Training](https://skillbuilder.aws/) - Free security courses and certification prep
- [Domain 2 Review: Security and Compliance](https://skillbuilder.aws/learn/C2QPSGKG9W/domain-2-review-aws-certified-cloud-practitioner-clfc02--english/TB2UW9ZDZ6) - Official security domain training
- [AWS Security Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive security learning paths

### AWS Security Resources
- [AWS Security Hub](https://aws.amazon.com/security-hub/) - Centralized security management
- [AWS Shield](https://aws.amazon.com/shield/) - DDoS protection
- [AWS WAF](https://aws.amazon.com/waf/) - Web application firewall
- [AWS GuardDuty](https://aws.amazon.com/guardduty/) - Threat detection

---

**Next**: [Deployment & Operating Methods (Domain 3)](deployment-methods.md)
