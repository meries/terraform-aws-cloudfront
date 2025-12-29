# Default Example - Quick Start

This is the default example showing the most common usage of the CloudFront module.

## What This Example Does

- Creates CloudFront distributions from YAML configuration
- Automatically creates Origin Access Controls (OAC) for S3 origins
- Optionally creates Route53 DNS records
- Optionally creates S3 log buckets with lifecycle policies
- Optionally enables CloudWatch monitoring with alarms

## Prerequisites

1. AWS credentials configured
2. ACM certificate in `us-east-1` (if using custom domains)
3. Origins (create before deploying)

## Directory Structure

You need to create the following YAML configuration files:

```
.
├── main.tf                             
├── distributions/
│   └── website.yaml                    # Your distribution configuration
├── policies/
│   └── cache-policies.yaml             # Optional: Custom cache policies
│   └── origin-request-policies.yaml    # Optional: Custom origin request policies
│   └── response-headers-policies.yaml  # Optional: Custom response header policies
├── functions/
│   ├── cloudfront-functions.yaml       # Optional: CloudFront Functions
│   └── src/
│       └── url-rewrite.js
└── key-value-stores/
    └── stores.yaml                     # Optional: Key Value Stores
```

## Minimal Configuration Files

**main.tf**

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
  version = "1.0.1"

  # Default: Path to your YAML configurations (can be overridden if needed)
  # distributions_path    = "${path.module}/distributions"
  # policies_path         = "${path.module}/policies"
  # functions_path        = "${path.module}/functions"
  # key_value_stores_path = "${path.module}/key-value-stores"

  # Optional: Resource naming
  naming_prefix = ""
  naming_suffix = ""

  # Optional: Automation features
  create_log_buckets = false
  enable_monitoring  = false

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
```


**distributions/website.yaml:**
```yaml
enabled: true
comment: "Website"
price_class: "PriceClass_100"
default_root_object: "index.html"
ipv6_enabled: true

aliases:
  - www.example.com

# DNS record creation control
# Set to false if you want to manage DNS records manually
# Default: true (Route53 zones are automatically detected based on alias domain names)
create_dns_records: false

certificate:
  acm_certificate_arn: "arn:aws:acm:us-east-1:123:certificate/xxx"

origins:
  - id: s3-website
    domain_name: bucket.s3.eu-west-1.amazonaws.com
    type: s3

# Behavior sorting mode: 'auto' (automatic sorting) or 'manual' (keep YAML order)
# Default: auto
behavior_sorting: auto

default_behavior:
  target_origin_id: s3-website
  cache_policy_name: "website-cache"
  response_headers_policy_name: "security-headers"

# Ordered behaviors - specific path patterns with custom caching rules
# These take precedence over default_behavior for matching requests
behaviors:
  # API endpoints - minimal caching, forward auth headers
  - path_pattern: "/api/*"
    target_origin_id: s3-website
    cache_policy_name: "api-cache"
    viewer_protocol_policy: https-only
    allowed_methods: [GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE]

  # Static assets - aggressive caching
  - path_pattern: "/assets/*"
    target_origin_id: s3-website
    cache_policy_name: "website-cache"
    response_headers_policy_name: "cors-public"
    viewer_protocol_policy: redirect-to-https
    compress: true

custom_error_responses:
  - error_code: 404
    response_code: 200
    response_page_path: "/index.html"

# CloudFront access logs configuration
logging:
  bucket: "my-cloudfront-logs.s3.amazonaws.com"
  prefix: "cloudfront/website/"
  include_cookies: false

# Enable additional CloudWatch metrics for detailed monitoring
enable_additional_metrics: true
```

**policies/cache-policies.yaml:**
```yaml
---
# Cache policy for website
website-cache:
  comment: "Optimized cache for static website"
  default_ttl: 86400
  max_ttl: 31536000
  min_ttl: 0
  enable_accept_encoding_gzip: true
  enable_accept_encoding_brotli: true
  cookies_behavior: none
  headers_behavior: none
  query_strings_behavior: none

# Minimal cache for API
api-cache:
  comment: "Minimal cache for API"
  default_ttl: 0
  max_ttl: 300
  cookies_behavior: all
  headers_behavior: whitelist
  headers:
    - Authorization
  query_strings_behavior: all
```

**policies/origin-request-policies.yaml:**
```yaml
# Forward all headers, cookies, and query strings to origin
all-viewer:
  comment: "Forward all viewer headers, cookies, and query strings to origin"
  cookies_behavior: all
  headers_behavior: allViewer
  query_strings_behavior: all

# CORS policy for S3 origins
cors-s3:
  comment: "CORS headers for S3 origin"
  cookies_behavior: none
  headers_behavior: whitelist
  headers:
    - Origin
    - Access-Control-Request-Method
    - Access-Control-Request-Headers
  query_strings_behavior: none
```

**policies/response-headers-policies.yaml:**
```yaml
# Complete security headers policy
security-headers:
  comment: "Comprehensive security headers for enhanced protection"
  security_headers:
    # Strict Transport Security (HSTS)
    strict_transport_security:
      max_age_sec: 31536000
      include_subdomains: true
      preload: true
      override: true

    # Content Security Policy
    content_security_policy:
      value: "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'"
      override: true

    # X-Content-Type-Options
    content_type_options: true
    content_type_options_override: true

    # X-Frame-Options
    frame_options:
      value: "DENY"
      override: true

    # Referrer Policy
    referrer_policy:
      value: "strict-origin-when-cross-origin"
      override: true

    # XSS Protection
    xss_protection:
      enabled: true
      mode_block: true
      override: true

# CORS policy for public assets
cors-public:
  comment: "CORS headers for public static assets"
  cors_config:
    allow_credentials: false
    allow_headers:
      - "*"
    allow_methods:
      - "GET"
      - "HEAD"
      - "OPTIONS"
    allow_origins:
      - "*"
    max_age_sec: 86400
    origin_override: true
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

## Next Steps

- See the [multi-environment example](https://github.com/meries/terraform-aws-cloudfront/tree/main/examples/multi-environment) for production setups
- Read the [main README]([../../README.md](https://github.com/meries/terraform-aws-cloudfront/blob/main/README.md)) for full documentation
