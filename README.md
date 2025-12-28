# Terraform CloudFront Multi-Distributions

[![Terraform Tests](https://github.com/meries/terraform-aws-cloudfront/actions/workflows/terraform-tests.yml/badge.svg?branch=main)](https://github.com/meries/terraform-aws-cloudfront/actions/workflows/terraform-tests.yml)

Terraform module for managing multiple CloudFront distributions using YAML configuration, designed for multi-environment deployments on AWS.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Directory Structure

```
terraform/
├── main.tf
├── distributions/
│   └── website.yaml
├── policies/
│   └── cache-policies.yaml
├── functions/
│   ├── cloudfront-functions.yaml
│   └── src/
│       └── url-rewrite.js
└── key-value-stores/
    ├── stores.yaml
    └── data/
        └── feature-flags.json
```

## Quick Start

> For a complete getting started guide with full configuration examples, see the [examples/](examples/) including:
>- [default](examples/default/) - Quick start with common patterns
>- [multi-environment](examples/multi-environment/) - Production-ready multi-environment setup

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_key_value_store.kvs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_value_store) | resource |
| [aws_cloudfront_monitoring_subscription.metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_monitoring_subscription) | resource |
| [aws_cloudfront_origin_access_control.oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
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
| [aws_route53_zone.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_create_log_buckets"></a> [create\_log\_buckets](#input\_create\_log\_buckets) | Create S3 buckets for CloudFront logs automatically | `bool` | `false` | no |
| <a name="input_create_route53_records"></a> [create\_route53\_records](#input\_create\_route53\_records) | Create Route53 records automatically | `bool` | `false` | no |
| <a name="input_distributions_path"></a> [distributions\_path](#input\_distributions\_path) | Path to distributions YAML directory | `string` | `"./distributions"` | no |
| <a name="input_enable_default_tags"></a> [enable\_default\_tags](#input\_enable\_default\_tags) | Enable default tags | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable CloudWatch monitoring | `bool` | `false` | no |
| <a name="input_functions_path"></a> [functions\_path](#input\_functions\_path) | Path to CloudFront Functions directory | `string` | `"./functions"` | no |
| <a name="input_key_value_stores_path"></a> [key\_value\_stores\_path](#input\_key\_value\_stores\_path) | Path to Key Value Stores YAML directory | `string` | `"./key-value-stores"` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | Module version | `string` | `""` | no |
| <a name="input_monitoring_config"></a> [monitoring\_config](#input\_monitoring\_config) | CloudWatch monitoring configuration | <pre>object({<br/>    error_rate_threshold          = optional(number, 5)<br/>    error_rate_evaluation_periods = optional(number, 2)<br/>    sns_topic_arn                 = optional(string)<br/>    create_dashboard              = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names | `string` | `""` | no |
| <a name="input_naming_suffix"></a> [naming\_suffix](#input\_naming\_suffix) | Suffix for resource names | `string` | `""` | no |
| <a name="input_policies_path"></a> [policies\_path](#input\_policies\_path) | Path to policies YAML directory | `string` | `"./policies"` | no |
| <a name="input_route53_zones"></a> [route53\_zones](#input\_route53\_zones) | Route53 zone mapping | `map(string)` | `{}` | no |


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


## YAML Configuration Reference
### Distribution Configuration

Key configuration options for `distributions/*.yaml`:

- `enabled` - Enable/disable distribution
- `aliases` - Custom domain names (CNAME)
- `create_dns_records` - Auto-create Route53 records (default: true)
- `enable_additional_metrics` - CloudWatch metrics (costs $0.01/1000 requests)
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

## Features

**Core:**
- Multiple distributions & environments
- YAML-based configuration
- Automatic cache behavior sorting

**Automation:**
- Auto OAC for S3 origins
- Auto S3 log bucket policies
- Auto Route53 DNS records

**Functions:**
- CloudFront Functions (managed)
- Lambda@Edge (attach only)
- Key Value Stores support

**Monitoring & Security:**
- CloudWatch alarms & dashboards
- AWS WAF integration
- Origin Shield
- Access logs to S3

## Origin Groups (Automatic Failover)

CloudFront Origin Groups provide automatic failover between primary and secondary origins when specific HTTP error codes are returned. This enables high-availability configurations without external monitoring.

### Basic YAML Configuration

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

### Key Points

- **Exactly 2 members required** - Primary and secondary origins only
- **Valid status codes** - 403, 404, 500, 502, 503, 504
- **Automatic failover** - Happens in < 1 second when primary returns configured status code
- **Behaviors can reference origin groups** - Use `target_origin_id` to reference either an origin or origin group

See [docs/ORIGIN_GROUPS.md](docs/ORIGIN_GROUPS.md) for complete documentation including multi-region examples, best practices, and troubleshooting.

## CloudFront Functions vs Lambda@Edge

| Feature | CloudFront Functions | Lambda@Edge |
|---------|---------------------|-------------|
| **Module manages** | ✔️ Creates & deploys | ✖️ Only attaches |
| **Runtime** | JavaScript only | Multiple languages |
| **Event types** | viewer-request, viewer-response | All 4 types |
| **Performance** | Sub-millisecond | Milliseconds |
| **Cost** | Very cheap | More expensive |

See [docs/LAMBDA_EDGE.md](docs/LAMBDA_EDGE.md) for details.

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
