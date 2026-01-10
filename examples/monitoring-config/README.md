# Monitoring Configuration Example

Configure CloudWatch monitoring and alarms for CloudFront distributions with per-distribution granularity.

## What This Example Does

- Production API: Full monitoring with alarms, SNS notifications, and dashboard
- Staging Web: Monitoring disabled
- Shows `monitoring_defaults` at module level and per-distribution overrides

## Key Features

**Per-distribution monitoring in YAML:**

```yaml
monitoring:
  enabled: true
  enable_additional_metrics: true
  error_rate_threshold: 3
  error_rate_evaluation_periods: 2
  sns_topic_arn: arn:aws:sns:us-east-1:123456789012:alerts
  create_dashboard: true
```

**Module-level defaults:**

```hcl
monitoring_defaults = {
  enabled                   = false
  enable_additional_metrics = false
  error_rate_threshold      = 5
  error_rate_evaluation_periods = 2
  sns_topic_arn             = null
  create_dashboard          = false
}
```

## Configuration Files

### Directory Structure

```
.
├── main.tf
├── distributions/
│   ├── production-api.yaml      # Monitoring enabled
│   └── staging-web.yaml         # Monitoring disabled
└── policies/
    └── cache-policies.yaml
```
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
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront" {
  source  = "meries/cloudfront/aws"
  version = "1.0.4"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Monitoring defaults applied to all distributions
  # Can be overridden per distribution in YAML
  monitoring_defaults = {
    enabled                       = false
    error_rate_threshold          = 5
    error_rate_evaluation_periods = 2
    sns_topic_arn                 = null
    create_dashboard              = false
  }

  # Optional: Resource naming
  naming_prefix = "prod-"
  naming_suffix = ""

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
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

output "cloudwatch_alarms_4xx" {
  description = "CloudWatch 4xx error rate alarm ARNs"
  value = {
    for k, v in module.cloudfront.distribution_ids :
    k => "arn:aws:cloudwatch:us-east-1:${data.aws_caller_identity.current.account_id}:alarm:prod-${k}-4xx-error-rate"
  }
}

output "cloudwatch_alarms_5xx" {
  description = "CloudWatch 5xx error rate alarm ARNs"
  value = {
    for k, v in module.cloudfront.distribution_ids :
    k => "arn:aws:cloudwatch:us-east-1:${data.aws_caller_identity.current.account_id}:alarm:prod-${k}-5xx-error-rate"
  }
}

data "aws_caller_identity" "current" {}
```hcl


### distributions/production-api.yaml

```yaml
enabled: true

monitoring:
  enabled: true
  enable_additional_metrics: true
  error_rate_threshold: 3
  error_rate_evaluation_periods: 2
  sns_topic_arn: arn:aws:sns:us-east-1:123456789012:cloudfront-critical-alerts
  create_dashboard: true

origins:
  - id: api-backend
    type: custom
    domain_name: api.example.com
    custom_origin_config:
      protocol_policy: https-only

default_behavior:
  target_origin_id: api-backend
  viewer_protocol_policy: https-only
  cache_policy_name: api-optimized
  allowed_methods: ['GET', 'HEAD', 'OPTIONS', 'PUT', 'POST', 'PATCH', 'DELETE']
  compress: true

aliases:
  - api.example.com

certificate:
  acm_certificate_arn: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
  ssl_support_method: sni-only
  minimum_protocol_version: TLSv1.2_2021
```

### distributions/staging-web.yaml

```yaml
enabled: true

monitoring:
  enabled: false

origins:
  - id: s3-staging-web
    type: s3
    domain_name: my-staging-website-bucket.s3.eu-west-1.amazonaws.com

default_behavior:
  target_origin_id: s3-staging-web
  viewer_protocol_policy: redirect-to-https
  cache_policy_name: web-optimized
  compress: true

aliases:
  - staging.example.com
```

### policies/cache-policies.yaml

```yaml
api-optimized:
  comment: Optimized caching for API
  default_ttl: 300
  max_ttl: 3600
  min_ttl: 0
  parameters_in_cache_key_and_forwarded_to_origin:
    enable_accept_encoding_gzip: true
    enable_accept_encoding_brotli: true
    query_strings_config:
      query_string_behavior: all
    headers_config:
      header_behavior: whitelist
      headers:
        - Authorization
    cookies_config:
      cookie_behavior: none

web-optimized:
  comment: Optimized for static content
  default_ttl: 86400
  max_ttl: 31536000
  min_ttl: 0
  parameters_in_cache_key_and_forwarded_to_origin:
    enable_accept_encoding_gzip: true
    enable_accept_encoding_brotli: true
    query_strings_config:
      query_string_behavior: none
    headers_config:
      header_behavior: none
    cookies_config:
      cookie_behavior: none
```

## What Gets Created

**For production-api:**
- CloudWatch alarms for 4xx and 5xx error rates (threshold: 3%)
- CloudWatch dashboard with requests, error rates, and data transfer widgets
- SNS notifications when alarms trigger
- Additional real-time metrics

**For staging-web:**
- No monitoring resources

## Monitoring Resources

**CloudWatch Alarms (per monitored distribution):**
- 4xx error rate alarm (5-minute periods)
- 5xx error rate alarm (5-minute periods)

**CloudWatch Dashboard (when `create_dashboard: true`):**
- Requests widget
- Error rates widget (4xx/5xx)
- Data transfer widget (bytes up/down)

## Costs

- **Alarms**: First 10 free, then $0.10/alarm/month
- **Dashboards**: First 3 free, then $3.00/dashboard/month
- **Additional Metrics**: $0.01 per 1,000 requests (when `enable_additional_metrics: true`)

## Migration from v1.0.3

**Before:**
```hcl
enable_monitoring = true
monitoring_config = {
  error_rate_threshold = 5
  sns_topic_arn        = "arn:aws:sns:..."
  create_dashboard     = true
}
```

**After:**
```hcl
monitoring_defaults = {
  enabled              = true
  error_rate_threshold = 5
  sns_topic_arn        = "arn:aws:sns:..."
  create_dashboard     = true
}
```

Override per distribution in YAML if needed.
