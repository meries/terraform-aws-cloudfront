# Origin Groups Example - High Availability S3 Failover

This example demonstrates CloudFront Origin Groups for automatic failover between a primary and backup S3 bucket across different AWS regions.

## Architecture

```
CloudFront Distribution
  └─ Origin Group: s3-failover-group
      ├─ Primary:   my-website-primary.s3.us-east-1.amazonaws.com
      └─ Secondary: my-website-backup.s3.us-west-2.amazonaws.com

Failover triggers: HTTP 500, 502, 503, 504
Failover time: < 1 second
```

## What This Example Does

- Creates a CloudFront distribution with origin group failover
- Configures primary S3 origin in us-east-1
- Configures backup S3 origin in us-west-2
- Automatically fails over when primary returns 500/502/503/504 errors
- Uses AWS managed cache policy (CachingOptimized)

## Prerequisites

1. AWS credentials configured
2. S3 buckets in different regions (create before deploying)

**Create the S3 buckets:**

```bash
# Create primary bucket (us-east-1)
aws s3 mb s3://my-website-primary --region us-east-1

# Create backup bucket (us-west-2)
aws s3 mb s3://my-website-backup --region us-west-2
```

**Recommended:** Enable S3 Cross-Region Replication to keep buckets synchronized.

## Configuration Files

### main.tf

```hcl
terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront" {
  source  = "meries/cloudfront/aws"
  version = "1.0.1"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Default: Path to your YAML configurations (can be overridden if needed)
  # distributions_path      = "${path.module}/distributions"
  # policies_path           = "${path.module}/policies"
  # functions_path          = "${path.module}/functions"
  # key_value_stores_path   = "${path.module}/key-value-stores"
  # trusted_key_groups_path = "${path.module}/trusted-key-groups"

  # Optional: Resource naming
  naming_prefix = "ha-"

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Example     = "origin-groups-failover"
  }
}

# Outputs
output "distribution_ids" {
  description = "CloudFront distribution IDs"
  value       = module.cloudfront.distribution_ids
}

output "distribution_domain_names" {
  description = "CloudFront domain names"
  value       = module.cloudfront.distribution_domain_names
}
```

### distributions/ha-website.yaml

```yaml
enabled: true
comment: "HA Website with automatic S3 failover"

# Origins: Primary and Secondary S3 buckets
origins:
  - id: primary-s3-us-east-1
    domain_name: my-website-primary.s3.us-east-1.amazonaws.com
    type: s3

  - id: backup-s3-us-west-2
    domain_name: my-website-backup.s3.us-west-2.amazonaws.com
    type: s3

# Origin Groups: Automatic failover configuration
origin_groups:
  - id: s3-failover-group
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: primary-s3-us-east-1
      - origin_id: backup-s3-us-west-2

# Default Behavior: Reference the origin group
default_behavior:
  target_origin_id: s3-failover-group
  cache_policy_name: CachingOptimized
  viewer_protocol_policy: redirect-to-https
  compress: true
  allowed_methods:
    - GET
    - HEAD
    - OPTIONS
  cached_methods:
    - GET
    - HEAD

# Price Class
price_class: PriceClass_100

# HTTP Versions
http_version: http2and3

# IPv6
ipv6_enabled: true
```

### policies/cache-policies.yaml

```yaml
# Empty - uses AWS managed policy "CachingOptimized"
```

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Get the CloudFront domain name
terraform output distribution_domain_names
```

## Testing Failover

After deployment, test the failover:

```bash
# Get CloudFront domain name
terraform output distribution_domain_names

# Upload test file to primary bucket
echo "Primary content" > test.html
aws s3 cp test.html s3://my-website-primary/

# Verify CloudFront serves from primary
curl https://d111111abcdef8.cloudfront.net/test.html

# Simulate primary failure by deleting file
aws s3 rm s3://my-website-primary/test.html

# Upload to backup bucket
echo "Backup content" > test.html
aws s3 cp test.html s3://my-website-backup/

# CloudFront should now serve from backup (< 1 second failover)
curl https://d111111abcdef8.cloudfront.net/test.html
```

## Key Configuration

### Origin Groups in YAML

```yaml
origin_groups:
  - id: s3-failover-group
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: primary-s3-us-east-1
      - origin_id: backup-s3-us-west-2
```

### Referencing in Behaviors

```yaml
default_behavior:
  target_origin_id: s3-failover-group  # References origin group, not origin
```

## Limitations

- Exactly 2 members required (primary + secondary)
- Valid status codes: 403, 404, 500, 502, 503, 504
- No active health checks (failover based on actual request errors)
- No weighted routing (always tries primary first)

## Next Steps

- Enable S3 Cross-Region Replication
- Add CloudWatch alarms for 5xx error rates
- Configure custom error responses
- Test with your actual S3 buckets

## Complete Documentation

See [docs/ORIGIN_GROUPS.md](https://github.com/meries/terraform-aws-cloudfront/blob/main/docs/ORIGIN_GROUPS.md) for:
- Multi-region ALB failover examples
- Multiple origin groups in one distribution
- Best practices and monitoring
- Troubleshooting guide
