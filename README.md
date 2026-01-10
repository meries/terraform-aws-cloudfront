# Terraform CloudFront Multi-Distributions

[![Terraform Tests](https://github.com/meries/terraform-aws-cloudfront/actions/workflows/terraform-tests.yml/badge.svg?branch=main)](https://github.com/meries/terraform-aws-cloudfront/actions/workflows/terraform-tests.yml)

Terraform module for managing multiple CloudFront distributions using YAML configuration, designed for multi-environment deployments on AWS.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.27 |
| <a name="requirement_aws_cli"></a> [aws-cli](#requirement\_aws\_cli) | >= 2.0 (required for cache invalidation feature) |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Directory Structure

```
terraform/
├── main.tf
├── distributions/
│   ├── production-api.yaml       # Filename = distribution name
│   └── staging-web.yaml
├── policies/
│   └── cache-policies.yaml
├── functions/
│   ├── cloudfront-functions.yaml
│   └── src/
│       └── url-rewrite.js
├── key-value-stores/
│   ├── stores.yaml
│   └── data/
│       └── feature-flags.json
└── trusted-key-groups/
    ├── trusted-key-groups.yaml
    └── keys/
        └── public-key.pem
```

## Quick Start
> [!TIP]
For a complete getting started guide with full configuration examples, see the [examples/](examples/) including:
- [default](examples/default/) - Quick start with common patterns
- [multi-environment](examples/multi-environment/) - Production-ready multi-environment setup
- [origin-groups](examples/origin-groups/) - High-availability with automatic failover
- [signed-urls](examples/signed-urls/) - Private content with Trusted Key Groups
- [monitoring-config](examples/monitoring-config/) - CloudWatch alarms and dashboards

<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_key_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_group) | resource |
| [aws_cloudfront_key_value_store.kvs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_value_store) | resource |
| [aws_cloudfront_monitoring_subscription.metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_monitoring_subscription) | resource |
| [aws_cloudfront_origin_access_control.oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_public_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_public_key) | resource |
| [aws_cloudfront_response_headers_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudfrontkeyvaluestore_key.items](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfrontkeyvaluestore_key) | resource |
| [aws_cloudwatch_dashboard.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.error_rate_4xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_rate_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_route53_record.cloudfront_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudfront_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [null_resource.cache_invalidation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_route53_zone.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of tags to apply to all resources created by this module. Example: { Environment = 'production', ManagedBy = 'terraform' } | `map(string)` | `{}` | no |
| <a name="input_create_log_buckets"></a> [create\_log\_buckets](#input\_create\_log\_buckets) | Automatically create and configure S3 buckets for CloudFront access logs with appropriate policies, lifecycle rules, and encryption | `bool` | `false` | no |
| <a name="input_distributions_path"></a> [distributions\_path](#input\_distributions\_path) | Path to the directory containing CloudFront distribution YAML configuration files. Each YAML file defines a distribution with origins, behaviors, and cache policies | `string` | `"./distributions"` | no |
| <a name="input_enable_default_tags"></a> [enable\_default\_tags](#input\_enable\_default\_tags) | Enable automatic addition of default tags (ManagedBy='terraform', ModuleVersion) to all resources, merged with common\_tags | `bool` | `true` | no |
| <a name="input_functions_path"></a> [functions\_path](#input\_functions\_path) | Path to the directory containing CloudFront Functions JavaScript files. Each .js file represents a function that runs at edge locations | `string` | `"./functions"` | no |
| <a name="input_key_value_stores_path"></a> [key\_value\_stores\_path](#input\_key\_value\_stores\_path) | Path to the directory containing CloudFront KeyValueStore YAML files for low-latency data storage accessible from CloudFront Functions | `string` | `"./key-value-stores"` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | Version identifier for this module instance, added as a tag to all resources when enable\_default\_tags is true. Example: '1.0.0' | `string` | `""` | no |
| <a name="input_monitoring_defaults"></a> [monitoring\_defaults](#input\_monitoring\_defaults) | Default monitoring configuration applied to all distributions unless overridden in distribution YAML. Controls CloudWatch alarms, dashboards, and additional metrics per distribution | <pre>object({<br>    enabled                       = optional(bool, false)<br>    enable_additional_metrics     = optional(bool, false)<br>    error_rate_threshold          = optional(number, 5)<br>    error_rate_evaluation_periods = optional(number, 2)<br>    sns_topic_arn                 = optional(string)<br>    create_dashboard              = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix string to prepend to all resource names. Useful for environment segregation (e.g., 'prod-', 'staging-') or multi-tenant deployments | `string` | `""` | no |
| <a name="input_naming_suffix"></a> [naming\_suffix](#input\_naming\_suffix) | Suffix string to append to all resource names. Useful for regional identification (e.g., '-us-east-1') or versioning (e.g., '-v2') | `string` | `""` | no |
| <a name="input_policies_path"></a> [policies\_path](#input\_policies\_path) | Path to the directory containing CloudFront policy YAML files (cache policies, origin request policies, response headers policies) | `string` | `"./policies"` | no |
| <a name="input_trusted_key_groups_path"></a> [trusted\_key\_groups\_path](#input\_trusted\_key\_groups\_path) | Path to the directory containing Trusted Key Groups YAML files for signed URLs and signed cookies (private content access control) | `string` | `"./trusted-key-groups"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_policy_ids"></a> [cache\_policy\_ids](#output\_cache\_policy\_ids) | Map of cache policy IDs |
| <a name="output_cloudfront_function_arns"></a> [cloudfront\_function\_arns](#output\_cloudfront\_function\_arns) | Map of CloudFront Function ARNs |
| <a name="output_cloudfront_function_etags"></a> [cloudfront\_function\_etags](#output\_cloudfront\_function\_etags) | Map of CloudFront Function ETags |
| <a name="output_distribution_arns"></a> [distribution\_arns](#output\_distribution\_arns) | Map of distribution ARNs |
| <a name="output_distribution_domain_names"></a> [distribution\_domain\_names](#output\_distribution\_domain\_names) | Map of CloudFront domain names |
| <a name="output_distribution_hosted_zone_ids"></a> [distribution\_hosted\_zone\_ids](#output\_distribution\_hosted\_zone\_ids) | Map of CloudFront hosted zone IDs |
| <a name="output_distribution_ids"></a> [distribution\_ids](#output\_distribution\_ids) | Map of distribution IDs |
| <a name="output_key_value_store_arns"></a> [key\_value\_store\_arns](#output\_key\_value\_store\_arns) | Map of Key Value Store names to ARNs |
| <a name="output_key_value_store_ids"></a> [key\_value\_store\_ids](#output\_key\_value\_store\_ids) | Map of Key Value Store names to IDs |
| <a name="output_oac_ids"></a> [oac\_ids](#output\_oac\_ids) | Map of Origin Access Control IDs |
| <a name="output_public_key_ids"></a> [public\_key\_ids](#output\_public\_key\_ids) | Map of Public Key names to IDs (composite key: keygroup\_\_keyname) |
| <a name="output_trusted_key_group_ids"></a> [trusted\_key\_group\_ids](#output\_trusted\_key\_group\_ids) | Map of Trusted Key Group names to IDs |
<!-- END_TF_DOCS -->


## YAML Configuration Reference
### Distribution Configuration

Key configuration options for `distributions/*.yaml`:

- `enabled` - Enable/disable distribution
- `aliases` - Custom domain names (CNAME)
- `create_dns_records` - Auto-create Route53 records (default: true)
- `monitoring` - CloudWatch alarms, dashboards, and additional metrics (see Monitoring section)
- `behavior_sorting` - `auto` or `manual` (default: auto)
- `web_acl_id` - AWS WAF Web ACL ARN (WAFv2, us-east-1)
- `origins` - Origin configurations (S3, custom)
- `default_behavior` - Default cache behavior
- `behaviors` - Ordered cache behaviors
- `logging` - CloudFront access logs
- `certificate` - ACM certificate ARN

### Policy Types

1. **Cache Policies** (`policies/cache-policies.yaml`)
   - TTL configuration (min, default, max)
   - Compression (gzip, brotli)
   - Cookie/header/query string forwarding

2. **Origin Request Policies** (`policies/origin-request-policies.yaml`)
   - Control what's forwarded to origin
   - Cookie/header/query string whitelist

3. **Response Headers Policies** (`policies/response-headers-policies.yaml`)
   - Security headers (HSTS, CSP, X-Frame-Options, etc.)
   - CORS configuration
   - Custom headers

4. **CloudFront Functions** (`functions/cloudfront-functions.yaml`)
   - Lightweight request/response manipulation
   - JavaScript runtime
   - See [docs/LAMBDA_EDGE.md](docs/LAMBDA_EDGE.md) for comparison with Lambda@Edge

**Complete examples with all options:** [examples/default/](examples/default/)

## Origins

### S3 Origins

S3 origins support Origin Access Control (OAC) for secure, private access to S3 buckets.

```yaml
origins:
  - id: my-s3-origin
    type: s3
    domain_name: my-bucket.s3.eu-west-1.amazonaws.com
    s3_origin_config:
      origin_access_control: true
```

### Custom Origins

Custom origins (HTTP/HTTPS servers, ALB, API Gateway, etc.) support advanced configuration.

```yaml
origins:
  - id: my-api-origin
    type: custom
    domain_name: api.example.com
    connection_attempts: 3                 # 1-3 attempts (default: 3)
    connection_timeout: 10                 # 1-10 seconds (default: 10)
    custom_origin_config:
      http_port: 80
      https_port: 443
      protocol_policy: https-only          # https-only | http-only | match-viewer
      ssl_protocols: [TLSv1.2]             # TLSv1, TLSv1.1, TLSv1.2, SSLv3
      keepalive_timeout: 60                # 1-180 seconds (default: 5)
      read_timeout: 30                     # 1-180 seconds (default: 30)
```

**Key parameters:**
- `connection_attempts`: Number of times CloudFront attempts to connect to the origin (1-3)
- `connection_timeout`: Timeout for each connection attempt in seconds (1-10)
- `protocol_policy`: How CloudFront connects to your origin
- `ssl_protocols`: SSL/TLS protocols for HTTPS connections
- `keepalive_timeout`: Connection reuse timeout (improves performance)
- `read_timeout`: Response timeout from origin

### Origin Groups (Automatic Failover)

Origin Groups provide automatic failover between primary and secondary origins when specific HTTP error codes are returned.

```yaml
origins:
  - id: primary-s3
    domain_name: primary-bucket.s3.us-east-1.amazonaws.com
    type: s3
  - id: secondary-s3
    domain_name: backup-bucket.s3.us-west-2.amazonaws.com
    type: s3

origin_groups:
  - id: ha-s3-group
    failover_criteria:
      status_codes: [500, 502, 503, 504]
    members:
      - origin_id: primary-s3
      - origin_id: secondary-s3

default_behavior:
  target_origin_id: ha-s3-group
```

**Key points:**
- Exactly 2 members required (primary and secondary)
- Valid status codes: 403, 404, 500, 502, 503, 504
- Automatic failover in < 1 second
- Behaviors can reference origins or origin groups

See [docs/ORIGIN_GROUPS.md](docs/ORIGIN_GROUPS.md) for complete documentation including multi-region examples and best practices.

## CloudFront Functions vs Lambda@Edge

| Feature | CloudFront Functions | Lambda@Edge |
|---------|---------------------|-------------|
| **Module manages** | ✔️ Creates & deploys | ✖️ Only attaches |
| **Runtime** | JavaScript only | Multiple languages |
| **Event types** | viewer-request, viewer-response | All 4 types |
| **Performance** | Sub-millisecond | Milliseconds |
| **Cost** | Very cheap | More expensive |

See [docs/LAMBDA_EDGE.md](docs/LAMBDA_EDGE.md) for details.

## Cache Invalidation

Automatically invalidate CloudFront cache when deploying changes:

```yaml
default_behavior:
  target_origin_id: s3-origin
  cache_policy_name: general
  cache_invalidation: true  # Invalidates /* on every apply (default: false)

behaviors:
  - path_pattern: "/api/*"
    cache_invalidation: true  # Invalidates /api/* on every apply
    function_associations:
      - event_type: viewer-request
        function_name: api-auth

  - path_pattern: "/assets/*"
    cache_invalidation: false  # No invalidation (versioned files)
```

**Behavior:**
- `cache_invalidation: true` triggers invalidation on every `terraform apply`
- Invalidates `/*` for default behavior or specific `path_pattern` for ordered behaviors
- First 1000 invalidations per month are free (Please be mindful of the cost).

## Monitoring (CloudWatch Alarms & Dashboards)

Configure CloudWatch monitoring per distribution with alarms and dashboards:

```yaml
monitoring:
  enabled: true                          # Enable/disable monitoring for this distribution
  enable_additional_metrics: true        # Enable real-time CloudFront metrics
  error_rate_threshold: 3                # Error rate % threshold for alarms
  error_rate_evaluation_periods: 2       # Number of periods before alarm triggers
  sns_topic_arn: arn:aws:sns:us-east-1:123456789012:alerts  # SNS topic for notifications
  create_dashboard: true                 # Create CloudWatch dashboard
```

**What gets created when `enabled: true`:**
- CloudWatch alarms for 4xx and 5xx error rates
- CloudWatch dashboard (when `create_dashboard: true`)
- SNS notifications when alarms trigger (if `sns_topic_arn` provided)
- Additional real-time metrics (when `enable_additional_metrics: true`)

**Module-level defaults** can be set via `monitoring_defaults` variable to apply to all distributions (overridable per distribution).

**Costs:**
- Alarms: First 10 free, then $0.10/alarm/month
- Dashboards: First 3 free, then $3.00/dashboard/month
- Additional metrics: $0.01 per 1,000 requests

See `examples/monitoring-config/` for complete setup.

## Trusted Key Groups (Signed URLs & Cookies)

Restrict access to private content using signed URLs or signed cookies:

**1. Define key groups in `trusted-key-groups/trusted-key-groups.yaml`:**

```yaml
video-streaming:
  comment: "Keys for premium video content"
  public_keys:
    - name: "production-key-2024"
      comment: "Production signing key"
      encoded_key_file: "keys/prod-key.pem"  # Path relative to trusted-key-groups/

    - name: "production-key-2025"
      comment: "Rotation key for 2025"
      encoded_key: |
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
        -----END PUBLIC KEY-----
```

**2. Reference in distribution behaviors:**

```yaml
behaviors:
  - path_pattern: "/premium/*"
    target_origin_id: s3-premium
    trusted_key_group_name: "video-streaming"  # Module-managed key group
```

**How it works:**
- Your app generates signed URLs/cookies using the **private key**
- CloudFront verifies signatures using the **public key** from the key group
- Invalid signatures are rejected with 403 Forbidden

See `examples/signed-urls/` for complete setup.

## CloudFront Access Logs

```yaml
logging:
  bucket: "my-cloudfront-logs.s3.amazonaws.com"
  prefix: "cloudfront/my-distribution/"
  include_cookies: false
```

Set `create_log_buckets = true` to auto-create S3 buckets with:
- Versioning and encryption (AES256)
- Public access blocked
- Lifecycle policy (Glacier after 90 days, delete after 365 days)

## Security Features

### AWS WAF

```yaml
web_acl_id: "arn:aws:wafv2:us-east-1:123456789012:global/webacl/my-waf/xxx"
```

Requirements:
- WAFv2 only (not classic WAF)
- Must be in `us-east-1` region
- Scope must be `CLOUDFRONT`

### Origin Shield

```yaml
origins:
  - id: my-origin
    type: s3
    origin_shield:
      enabled: true
      region: us-east-1
```

Benefits: Reduces origin load, protects against traffic spikes, lowers data transfer costs.

## AWS Managed Policies (IDs)

**Cache Policies:**
- `658327ea-f89d-4fab-a63d-7e88639e58f6` - CachingOptimized
- `4135ea2d-6df8-44a3-9df3-4b5a84be39ad` - CachingDisabled

**Response Headers:**
- `67f7725c-6f97-4210-82d7-5512b31e9d03` - SecurityHeadersPolicy
- `60669652-455b-4ae9-85a4-c4c02393f86c` - SimpleCORS

See [docs/AWS_MANAGED_POLICIES.md](docs/AWS_MANAGED_POLICIES.md) for complete list.

## Production Best Practices

**Protect resources from deletion:** Use AWS IAM tag-based policies. All resources inherit `common_tags`:

```json
{
  "Effect": "Deny",
  "Action": ["cloudfront:Delete*", "s3:DeleteBucket"],
  "Resource": "*",
  "Condition": { "StringEquals": { "aws:ResourceTag/Environment": "production" } }
}
```

## Documentation

- [docs/BEHAVIORS.md](docs/BEHAVIORS.md) - Cache behaviors automatic sorting
- [docs/LAMBDA_EDGE.md](docs/LAMBDA_EDGE.md) - CloudFront Functions vs Lambda@Edge
- [docs/ORIGIN_GROUPS.md](docs/ORIGIN_GROUPS.md) - Origin Groups for automatic failover
- [docs/AWS_MANAGED_POLICIES.md](docs/AWS_MANAGED_POLICIES.md) - AWS managed policies
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [examples/](examples/) - Usage examples

## License

MIT

---

Made with 🖤 by [Meries](https://github.com/meries)