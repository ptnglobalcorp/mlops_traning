# Domain 4: Billing, Pricing, and Support

**CLF-C02 Exam Domain 4 | 12% of Scored Content**

## Learning Objectives

By the end of this domain, you will be able to:

- Understand AWS pricing models
- Compare On-Demand, Reserved, and Spot pricing
- Use AWS TCO Calculator and Cost Explorer
- Understand AWS Free Tier
- Compare AWS support plans
- Identify cost optimization strategies

## AWS Pricing Models

### Overview

AWS offers multiple pricing models to provide flexibility and cost savings.

### Comparison Table

| Pricing Model | Commitment | Discount | Use Case | Best For |
|---------------|------------|----------|----------|----------|
| **On-Demand** | None | 0% | Flexible workloads | Short-term, unpredictable |
| **Reserved** | 1-3 years | Up to 75% | Steady-state workloads | Production, predictable |
| **Spot** | None | Up to 90% | Fault-tolerant | Batch, interruptible |
| **Savings Plans** | 1-3 years | Up to 72% | Consistent usage | Flexible alternative to RIs |

### On-Demand Pricing

**Characteristics**:
- Pay for what you use, by the second or hour
- No long-term commitment
- Highest cost, maximum flexibility
- No upfront payment

**Pricing Examples**:
- **EC2**: Pay per hour/second
- **S3**: Pay per GB/month + requests
- **Lambda**: Pay per request + compute time

**Use Cases**:
- Development/testing
- Short-term projects
- Applications with unpredictable usage
- Getting started quickly

---

## Reserved Instances (RIs)

### Overview

**Reserved Instances** provide significant discount compared to On-Demand pricing.

### RI Payment Options

| Option | Description | Savings |
|--------|-------------|---------|
| **All Upfront** | Pay full amount upfront | Highest discount |
| **Partial Upfront** | Pay portion upfront, rest monthly | Medium discount |
| **No Upfront** | Pay monthly over term | Lower discount |

### RI Term Lengths

| Term | Description |
|------|-------------|
| **1-Year** | Standard 1-year commitment |
| **3-Year** | Standard 3-year commitment |
| **Convertible** | Can change instance attributes |

### Reserved Instance Types

| Type | Scope | Flexibility |
|------|-------|------------|
| **Standard** | Regional | Same AZ, instance type, OS |
| **Convertible** | Regional | Change attributes during term |
| **Scheduled** | Specific time | Reservations for time windows |

### Use Cases

- Production workloads
- Steady-state usage (at least 75% of the time)
- Long-term applications
- Database workloads

**Break-even Analysis**: Generally break even at ~30-40% utilization for 1-year RI

---

## Savings Plans

### Overview

**Savings Plans** offer flexible pricing model with lower prices than On-Demand.

### Types

| Type | Scope | Discount | Use Case |
|------|-------|----------|----------|
| **Compute Savings Plans** | EC2, Fargate, Lambda | Up to 66% | Flexible compute usage |
| **EC2 Instance Savings Plans** | EC2 instances in region | Up to 72% | EC2-specific commitment |

### Savings Plans vs Reserved Instances

| Feature | Savings Plans | Reserved Instances |
|---------|---------------|-------------------|
| **Flexibility** | High (any instance, any size) | Low (specific attributes) |
| **Discount** | Up to 66-72% | Up to 75% |
| **Commitment** | Hourly spend commitment | Instance commitment |
| **Use Case** | Variable workloads | Stable, predictable workloads |

---

## Spot Instances

### Overview

**Spot Instances** use spare EC2 capacity at up to 90% discount.

### Characteristics

| Feature | Description |
|---------|-------------|
| **Price** | Based on supply and demand |
| **Interruption** | 2-minute warning before termination |
| **Pricing** | Up to 90% discount |
| **Availability** | Not guaranteed |

### Spot Pricing

**Spot Price**: Current market price (changes based on supply/demand)

**Maximum Price**: Your bid price (can be On-Demand price)

**When Interrupted**:
- Spot price exceeds your maximum price
- AWS needs capacity back

### Use Cases

- **Batch Processing**: Data processing, simulations
- **Big Data**: EMR clusters, Hadoop jobs
- **Containerized Workloads**: ECS, EKS
- **CI/CD**: Build and test pipelines
- **Web Crawling**: Distributed web scraping

### Spot Best Practices

1. **Use Spot Fleets**: Combine multiple instance types
2. **Fault-Tolerant Design**: Handle interruptions gracefully
3. **Checkpoints**: Save progress periodically
4. **Diversify**: Use multiple instance types and AZs

---

## AWS TCO Calculator

### Overview

**TCO Calculator** compares on-premises costs to AWS costs.

### What It Includes

| Cost Category | On-Premises | AWS |
|---------------|-------------|-----|
| **Hardware** | Servers, storage | Pay per use |
| **Software** | Licenses | Included (Linux) or pay (Windows) |
| **Power & Cooling** | Electricity | Included |
| **IT Labor** | Administration | Reduced (managed services) |
| **Data Center** | Facility costs | Included |

### Using the Calculator

1. **Select Workload Type**: Web apps, databases, analytics
2. **Input Current Infrastructure**: Servers, storage, network
3. **Adjust Assumptions**: Electricity cost, labor hours
4. **Compare Results**: 1-year, 3-year, 5-year projections

**Link**: https://aws.amazon.com/tco-calculator/

---

## Cost Explorer

### Overview

**Cost Explorer** provides visualization and analysis of AWS costs.

### Features

| Feature | Description |
|---------|-------------|
| **Cost & Usage** | View costs by service, region, tag |
| **Forecasting** | Predict future costs |
| **Anomaly Detection** | Unusual spending alerts |
| **Cost Allocation Tags** | Tag resources for cost tracking |
| **Reservation Coverage** | RI utilization tracking |

### Cost Allocation Tags

**Purpose**: Organize and track costs.

**Best Practices**:
- Tag all resources (Environment, Project, Owner, CostCenter)
- Use tag policies for compliance
- Enable cost allocation tags

**Common Tags**:
- `Environment`: Production, Development, Test
- `Project`: Project name
- `Owner`: Team or person
- `CostCenter`: Business unit

---

## AWS Free Tier

### Overview

**AWS Free Tier** offers free services for 12 months.

### Free Tier Offers

| Offer | Description |
|-------|-------------|
| **12 Months Free** | 750 hours/month EC2 (t2.micro/t3.micro) |
| **Always Free** | 1 million Lambda requests, 25 GB DynamoDB |
| **Trials** | 60-day free trials for some services |

### Popular Free Tier Services

| Service | Free Tier Limit | Duration |
|---------|----------------|----------|
| **EC2** | 750 hours/month (t2.micro or t3.micro) | 12 months |
| **Lambda** | 1 million requests/month + 400,000 GB-sec | Always |
| **S3** | 5 GB storage, 20,000 requests | Always |
| **RDS** | 750 hours/month (db.t2.micro/db.t3.micro) | 12 months |
| **DynamoDB** | 25 GB storage, 200 WCUs, 200 RCUs | Always |
| **CloudFront** | 1 TB data transfer | 12 months |

### Important Notes

- **Per Account**: Limits apply to entire account
- **Per Region**: Some services have per-region limits
- **Monitoring**: Watch for usage beyond free tier
- **Upgrade**: Free tier expires after 12 months for some services

---

## AWS Support Plans

### Overview

**AWS Support Plans** provide technical and operational support.

### Comparison Table

| Feature | Basic | Developer | Business | Enterprise |
|---------|-------|-----------|----------|------------|
| **Cost** | Free | $29/month | $100/month | $15,000/month |
| **Response Time** | Best effort | 24 hours | < 1 hour (critical) | < 15 minutes (critical) |
| **Trusted Advisor** | 7 checks | 7 checks | Full access | Full access |
| **Customer Service** | Community | Email | Phone, Chat | Phone, Chat, TAM |
| **Architecture Review** | - | - | 1/year | 2/year |
| **Case Severity** | 1-5 | 1-5 | 1-5 | 1-5 |
| **API Support** | No | No | Yes | Yes |

### Severity Levels

| Severity | Description | Response Time (Business) |
|----------|-------------|--------------------------|
| **1 (Critical)** | Production system down | < 1 hour |
| **2 (High)** | System impaired | < 4 hours |
| **3 (Medium)** | Minor impact | < 12 hours |
| **4 (Low)** | General questions | < 24 hours |

### Trusted Advisor

**Purpose**: Automated service recommendations.

**Categories**:

| Category | Checks |
|----------|--------|
| **Cost Optimization** | 20+ checks for cost savings |
| **Performance** | 20+ checks for performance |
| **Security** | 40+ checks for security gaps |
| **Fault Tolerance** | 20+ checks for HA |
| **Service Limits** | Check approaching limits |

**Basic vs Full Access**:
- **Basic**: 7 core security checks
- **Business/Enterprise**: All checks, actionable recommendations

---

## Cost Optimization Strategies

### 1. Right-Sizing

**What**: Use appropriately sized instances.

**How**:
- Use AWS Compute Optimizer
- Review CloudWatch metrics
- Test different instance types

**Savings**: 10-50% reduction

### 2. Use Reserved Instances or Savings Plans

**What**: Commit to usage for discounts.

**How**:
- Analyze usage patterns in Cost Explorer
- Purchase RIs or Savings Plans for steady workloads

**Savings**: Up to 75%

### 3. Use Spot Instances

**What**: Use spare capacity for fault-tolerant workloads.

**How**:
- Batch jobs, big data, containerized workloads
- Implement fault tolerance

**Savings**: Up to 90%

### 4. Delete Unused Resources

**What**: Remove unused instances, volumes, load balancers.

**How**:
- Use AWS Trusted Advisor
- Regular cleanup processes

**Savings**: Variable

### 5. Use Lifecycle Policies

**What**: Move data to cheaper storage over time.

**How**:
- S3 lifecycle policies (Standard → IA → Glacier)
- EBS snapshot lifecycle policies

**Savings**: 40-60% on storage

### 6. Monitor and Set Alerts

**What**: Track costs and receive alerts.

**How**:
- AWS Budgets
- Billing alerts
- Cost Explorer forecasts

**Savings**: Prevent overspending

---

## Exam Tips - Billing, Pricing, and Support

### High-Yield Topics

1. **Pricing Models**:
   - On-Demand = No commitment, highest cost
   - Reserved = 1-3 years, up to 75% savings
   - Spot = Up to 90% savings, interruptible
   - Savings Plans = Flexible, up to 72% savings

2. **TCO Calculator**:
   - Compare on-premises to AWS
   - Includes hardware, software, power, labor, facilities

3. **Cost Explorer**:
   - View costs by service, region, tag
   - Forecasting and anomaly detection
   - Cost allocation tags

4. **Free Tier**:
   - 12 months for some services (EC2, RDS)
   - Always free for others (Lambda, S3 limited)
   - Per account, not per user

5. **Support Plans**:
   - Basic = Free, community support
   - Developer = $29/month, email support
   - Business = $100/month, phone support, full Trusted Advisor
   - Enterprise = TAM, architecture reviews

6. **Trusted Advisor**:
   - Cost, Performance, Security, Fault Tolerance, Service Limits
   - 7 checks free (Basic), full access (Business+)

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Billing and Pricing Cheat Sheet](https://digitalcloud.training/aws-billing-and-pricing/) - Comprehensive billing and pricing reference for exam prep

### Official AWS Documentation
- [AWS Pricing](https://aws.amazon.com/pricing/)
- [TCO Calculator](https://aws.amazon.com/tco-calculator/)
- [Cost Explorer](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/ce-what-is.html)
- [AWS Support Plans](https://aws.amazon.com/premiumsupport/plans/)
- [Trusted Advisor](https://aws.amazon.com/premiumsupport/technology/trusted-advisor/)
- [AWS Skill Builder](https://skillbuilder.aws/) - Free billing courses and certification prep
- [AWS Builder Labs](https://builder.aws.com/) - Hands-on cost optimization labs
- [AWS Cost Management Learning Plans](https://skillbuilder.aws/learning-plan/8UUCEZGNX4/exam-prep-plan-aws-certified-cloud-practitioner-clfc02--english/1J2VTQSGU2) - Comprehensive cost management learning paths

### AWS Cost Management Resources
- [AWS Budgets](https://aws.amazon.com/aws-account-management/aws-budgets/) - Set custom cost and usage budgets
- [AWS Cost Explorer](https://aws.amazon.com/aws-account-management/aws-cost-explorer/) - Visualize and manage your AWS costs
- [AWS Compute Optimizer](https://aws.amazon.com/compute-optimizer/) - Optimize AWS resources
- [AWS Savings Plans](https://aws.amazon.com/savingsplans/) - Flexible pricing models

---

## Course Completion

Congratulations! You've completed the AWS Cloud Fundamentals (CLF-C02) module.

### Final Exam Tips

1. **Focus on High-Weight Domains**: Security (30%) and Services (34%)
2. **Memorize Service Comparisons**: Know when to use each service
3. **Understand Shared Responsibility**: Most important concept
4. **Practice with AWS Free Tier**: Hands-on experience
5. **Take Practice Exams**: Assess your readiness

### Next Steps

1. **Explore AWS Free Tier**: Get hands-on experience
2. **Take Practice Exams**: AWS Skill Builder
3. **Schedule Your Exam**: When you feel ready
4. **Join Study Groups**: Engage with AWS community

Good luck with your journey!
