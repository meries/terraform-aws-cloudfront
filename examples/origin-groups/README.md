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

You must create the S3 buckets yourself:

```bash
# Create primary bucket (us-east-1)
aws s3 mb s3://my-website-primary --region us-east-1

# Create backup bucket (us-west-2)
aws s3 mb s3://my-website-backup --region us-west-2
```

**Recommended:** Enable S3 Cross-Region Replication to keep buckets synchronized.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Files

- [main.tf](main.tf) - Module configuration
- [distributions/ha-website.yaml](distributions/ha-website.yaml) - Distribution with origin group
- [policies/cache-policies.yaml](policies/cache-policies.yaml) - Cache policies (uses AWS managed)

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

See [docs/ORIGIN_GROUPS.md](../../docs/ORIGIN_GROUPS.md) for:
- Multi-region ALB failover examples
- Multiple origin groups in one distribution
- Best practices and monitoring
- Troubleshooting guide
