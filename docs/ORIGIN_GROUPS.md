# CloudFront Origin Groups

## What are Origin Groups?

Origin Groups provide automatic failover capabilities for CloudFront distributions. When the primary origin fails (returns specific HTTP error codes), CloudFront automatically routes requests to a secondary backup origin.

This enables high availability configurations without external monitoring or DNS-based failover mechanisms.

## Use Cases

### High Availability
Ensure continuous content delivery even when your primary origin is unavailable:
- Primary S3 bucket in us-east-1, backup bucket in us-west-2
- Primary ALB in eu-west-1, backup ALB in us-east-1
- Automatic failover during regional AWS outages

### Disaster Recovery
Maintain service during:
- Origin maintenance windows
- Regional service disruptions
- Unexpected origin failures

### Multi-Region Resilience
Deploy content across multiple AWS regions with automatic failover to the nearest available region.

## YAML Configuration

### Basic Structure

```yaml
# distributions/ha-website.yaml
origins:
  - id: primary-s3
    domain_name: primary-bucket.s3.us-east-1.amazonaws.com
    type: s3

  - id: secondary-s3
    domain_name: backup-bucket.s3.us-west-2.amazonaws.com
    type: s3

origin_groups:
  - id: s3-failover-group
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: primary-s3
      - origin_id: secondary-s3

default_behavior:
  target_origin_id: s3-failover-group  # Reference origin group instead of single origin
```

### Configuration Parameters

**origin_groups** (array, optional)
- List of origin groups for the distribution
- Default: `[]` (no origin groups)

**origin_groups[].id** (string, required)
- Unique identifier for the origin group within the distribution
- Must be unique across all origins and origin groups in the distribution
- Can be referenced by behaviors via `target_origin_id`

**origin_groups[].failover_criteria.status_codes** (array, required)
- HTTP status codes that trigger failover to secondary origin
- Valid codes: `403`, `404`, `500`, `502`, `503`, `504`
- Multiple codes can be specified
- Example: `[500, 502, 503, 504]` for all server errors

**origin_groups[].members** (array, required)
- Exactly 2 members (primary and secondary)
- First member is primary, second is secondary

**origin_groups[].members[].origin_id** (string, required)
- Reference to an existing origin ID defined in the distribution
- Must match an `origins[].id` exactly

## Examples

### Example 1: S3 Multi-Region Failover

```yaml
origins:
  - id: primary-s3-us-east-1
    domain_name: my-website.s3.us-east-1.amazonaws.com
    type: s3

  - id: backup-s3-us-west-2
    domain_name: my-website-backup.s3.us-west-2.amazonaws.com
    type: s3

origin_groups:
  - id: s3-ha-group
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: primary-s3-us-east-1
      - origin_id: backup-s3-us-west-2

default_behavior:
  target_origin_id: s3-ha-group
  cache_policy_name: CachingOptimized
```

### Example 2: ALB/API Multi-Region Failover

```yaml
origins:
  - id: api-eu-west-1
    domain_name: api.eu-west-1.example.com
    type: custom
    protocol_policy: https-only
    https_port: 443

  - id: api-us-east-1
    domain_name: api.us-east-1.example.com
    type: custom
    protocol_policy: https-only
    https_port: 443

origin_groups:
  - id: api-failover
    failover_criteria:
      status_codes: [500, 502, 503, 504, 404]
    members:
      - origin_id: api-eu-west-1
      - origin_id: api-us-east-1

behaviors:
  - path_pattern: "/api/*"
    target_origin_id: api-failover
    cache_policy_name: CachingDisabled
```

### Example 3: Multiple Origin Groups

```yaml
origins:
  # Static content origins
  - id: static-primary
    domain_name: static.s3.us-east-1.amazonaws.com
    type: s3
  - id: static-backup
    domain_name: static-backup.s3.us-west-2.amazonaws.com
    type: s3

  # API origins
  - id: api-primary
    domain_name: api-primary.example.com
    type: custom
  - id: api-backup
    domain_name: api-backup.example.com
    type: custom

origin_groups:
  - id: static-ha
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: static-primary
      - origin_id: static-backup

  - id: api-ha
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: api-primary
      - origin_id: api-backup

default_behavior:
  target_origin_id: static-ha

behaviors:
  - path_pattern: "/api/*"
    target_origin_id: api-ha
```

## Failover Behavior

### How Failover Works

1. CloudFront receives a request and routes it to the primary origin
2. If the primary origin returns one of the configured status codes, CloudFront automatically retries the request to the secondary origin
3. If the secondary origin succeeds, CloudFront returns the response to the viewer
4. If both origins fail, CloudFront returns the error to the viewer

### Failover Timing

- Failover happens within **< 1 second**
- No external health checks required
- Based on actual request/response status codes
- CloudFront caches error responses according to `error_caching_min_ttl` (default: 10 seconds)

### Status Code Behavior

**Common Configurations:**

- **Server Errors Only:** `[500, 502, 503, 504]` - Only fail over on server errors
- **Include Not Found:** `[404, 500, 502, 503, 504]` - Also fail over when content is missing
- **Include Forbidden:** `[403, 404, 500, 502, 503, 504]` - Fail over on permission errors

## Best Practices

### 1. S3 Bucket Replication

For S3 origins, enable **Cross-Region Replication (CRR)** to keep backup buckets synchronized:

```hcl
resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.primary.id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.backup.arn
      storage_class = "STANDARD"
    }
  }
}
```

### 2. Consistent OAC Configuration

Ensure both S3 origins have Origin Access Control configured:

```yaml
origins:
  - id: primary-s3
    domain_name: primary.s3.amazonaws.com
    type: s3  # OAC automatically created

  - id: backup-s3
    domain_name: backup.s3.amazonaws.com
    type: s3  # OAC automatically created
```

### 3. Health Checks for Custom Origins

While CloudFront doesn't do active health checks, configure health checks at the origin level:
- ALB target group health checks
- Route53 health checks for DNS failover
- CloudWatch alarms for origin monitoring

### 4. Testing Failover

Test your failover configuration:

```bash
# Test primary origin failure
aws s3 rm s3://primary-bucket/test-file.html

# Verify CloudFront serves from secondary
curl -I https://d111111abcdef8.cloudfront.net/test-file.html

# Restore primary
aws s3 cp test-file.html s3://primary-bucket/
```

### 5. Monitor Failover Events

Use CloudWatch metrics to monitor origin failures:
- `OriginLatency` - Increased latency may indicate issues
- `4xxErrorRate` and `5xxErrorRate` - Track error rates
- Create alarms for sustained error rates

### 6. Cache Considerations

- CloudFront caches error responses for `error_caching_min_ttl` (default: 10 seconds)
- During a failover event, errors may be cached briefly
- Consider customizing `error_caching_min_ttl` in custom error responses:

```yaml
custom_error_responses:
  - error_code: 503
    error_caching_min_ttl: 0  # Don't cache 503 errors
```

## Limitations

### CloudFront Limitations

- **Exactly 2 members** - Origin groups support only primary + secondary (no tertiary)
- **No weighted routing** - CloudFront always tries primary first
- **No active health checks** - Failover only triggered by actual request failures
- **Status codes only** - Cannot fail over based on response time or other metrics

### Module Validations

The module enforces these validations:

1. **Member count:** Exactly 2 members required
2. **Origin references:** Members must reference existing origin IDs
3. **Unique IDs:** Origin group IDs must be unique within the distribution
4. **Valid status codes:** Only 403, 404, 500, 502, 503, 504 allowed

## Troubleshooting

### Failover Not Working

**Check origin group configuration:**
```bash
terraform plan | grep -A 20 "origin_group"
```

**Verify status codes match your error:**
- Primary origin returning 500 → Ensure `500` is in `status_codes`
- Primary returning 404 → Ensure `404` is in `status_codes`

**Check CloudWatch Logs:**
- Enable CloudFront logging
- Review origin request/response logs
- Look for `x-edge-detailed-result-type: Error`

### Both Origins Failing

**If both primary and secondary fail:**
- CloudFront returns the error to the viewer
- Check that both origins are configured correctly
- Verify network connectivity and security groups
- Review origin health in AWS Console

### Unexpected Failover

**If failing over too frequently:**
- Primary origin may have intermittent issues
- Check origin latency and error rates in CloudWatch
- Consider adjusting `status_codes` to be more selective
- Review origin logs for patterns

### Configuration Errors

**Common validation errors:**

```
Error: Origin groups must have exactly 2 members
→ Add or remove members to have exactly 2

Error: Origin group members must reference existing origin IDs
→ Check that origin_id matches an origins[].id exactly

Error: Valid failover status codes: 403, 404, 500, 502, 503, 504
→ Remove invalid status codes like 200, 301, etc.

Error: Behavior target_origin_id must reference an existing origin ID or origin group ID
→ Ensure target_origin_id matches either origins[].id or origin_groups[].id
```

## Monitoring

### Key Metrics

Monitor these CloudFront metrics in CloudWatch:

**Origin Metrics:**
- `OriginLatency` - Time from CloudFront edge to origin
- `OriginResponseTime` - Total time for origin to respond

**Error Metrics:**
- `4xxErrorRate` - Client errors
- `5xxErrorRate` - Server errors (triggers failover)

**Request Metrics:**
- `Requests` - Total requests to distribution
- `BytesDownloaded` - Data transferred to viewers

### CloudWatch Alarms

Create alarms for sustained failover conditions:

```hcl
resource "aws_cloudwatch_metric_alarm" "origin_errors" {
  alarm_name          = "cloudfront-origin-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5  # 5% error rate

  dimensions = {
    DistributionId = aws_cloudfront_distribution.dist.id
  }
}
```

### Logging

Enable CloudFront standard logs to track origin requests:

```yaml
logging:
  bucket: my-logs.s3.amazonaws.com
  prefix: cloudfront/
  include_cookies: false
```

Log fields useful for troubleshooting failover:
- `x-edge-location` - Edge location serving the request
- `x-edge-result-type` - Result type (Hit, Miss, Error)
- `x-edge-detailed-result-type` - Detailed error information
- `sc-status` - HTTP status code returned

## References

- [AWS CloudFront Origin Groups Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html)
- [CloudFront Metrics](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html)
- [S3 Cross-Region Replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)
- [CloudFront Error Codes](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/troubleshooting-response-errors.html)
