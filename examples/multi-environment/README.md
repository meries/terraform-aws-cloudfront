# Multi-Environment CloudFront Example

This example demonstrates how to manage CloudFront distributions across multiple environments (development, staging, production) with environment-specific configurations.

## Directory Structure

```
multi-environment/
├── README.md
├── dev/
│   ├── main.tf
│   ├── distributions/
│   │   └── website.yaml
│   ├── policies/
│   │   └── cache-policies.yaml
│   └── functions/
│       ├── cloudfront-functions.yaml
│       └── src/
│           └── url-rewrite.js
├── staging/
│   ├── main.tf
│   ├── distributions/
│   │   └── website.yaml
│   ├── policies/
│   │   ├── cache-policies.yaml
│   │   └── response-headers-policies.yaml
│   └── functions/
│       ├── cloudfront-functions.yaml
│       └── src/
│           └── url-rewrite.js
└── production/
    ├── main.tf
    ├── distributions/
    │   └── website.yaml
    ├── policies/
    │   ├── cache-policies.yaml
    │   ├── origin-request-policies.yaml
    │   └── response-headers-policies.yaml
    └── functions/
        ├── cloudfront-functions.yaml
        └── src/
            └── url-rewrite.js
```

## Environment Differences

| Feature | Development | Staging | Production |
|---------|------------|---------|------------|
| **Price Class** | PriceClass_100 | PriceClass_100 | PriceClass_All |
| **IPv6** | Disabled | Disabled | Enabled |
| **Origin Shield** | No | No | Yes |
| **WAF** | No | No | Yes |
| **Monitoring** | No | No | Yes (with SNS alerts) |
| **Logs** | No | No | Yes (with lifecycle) |
| **Route53 Auto** | No (manual) | Yes | Yes |
| **Caching** | Minimal (no-cache) | Standard | Aggressive |
| **Security Headers** | No | Yes | Yes (strict) |
| **Custom Error Pages** | No | No | Yes |

## Prerequisites

- Terraform >= 1.5.7
- AWS CLI configured with appropriate credentials
- ACM certificates in `us-east-1` (required for CloudFront)
- S3 buckets for origins (create before deploying)

## Deployment

### Development

```bash
cd dev
terraform init
terraform plan
terraform apply
```

### Staging

```bash
cd staging
terraform init
terraform plan
terraform apply
```

### Production

```bash
cd production
terraform init
terraform plan
terraform apply
```

## Configuration Notes

### Development
- **Caching disabled** for faster iteration
- **No monitoring** to reduce costs
- **Manual DNS** configuration
- **No security headers** for simplicity
- Uses AWS Managed CachingDisabled policy

### Staging
- **Standard caching** configuration
- **Security headers** for testing
- **Auto Route53** records
- Uses custom cache policy
- Tests production-like setup without full cost

### Production
- **Full feature set** enabled
- **Origin Shield** for better performance
- **WAF integration** for security
- **CloudWatch monitoring** with SNS alerts
- **Custom error pages** (404, 403, 500)
- **Security headers** with strict CSP
- **Custom origin request policy** for API caching
- **Lifecycle policies** on logs
- **Resource protection** strategies to prevent accidental deletion

## Notes

- Remember to update ACM certificate ARNs in distribution YAML files
- Update S3 bucket names to match your infrastructure
- For production, ensure WAF Web ACL is created separately
- SNS topic for alerts must exist before enabling monitoring
- **Production:** Use IAM tag-based policies to prevent accidental deletion (see main README)
