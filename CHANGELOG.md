# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.4] - 2026-01-10

### Changed
- **BREAKING: Per-distribution monitoring configuration**
  - Removed global variables: `enable_monitoring` and `monitoring_config`
  - Monitoring now configured per distribution in YAML: `monitoring.enabled`, `monitoring.error_rate_threshold`, etc.
  - New variable `monitoring_defaults` for default values applied to all distributions
  - CloudWatch alarms and dashboards created only for distributions with `monitoring.enabled: true`
  - Each distribution can have its own monitoring thresholds, SNS topics, and dashboard
  - Dashboards now created per distribution instead of one global dashboard
  - `enable_additional_metrics` moved into `monitoring` block for better organization (backward compatible)
  - Migration: Move monitoring settings from module variables to distribution YAML files
- **Custom origin configuration structure**
  - Custom origin parameters now read from `custom_origin_config` block in YAML (recommended)
  - Backward compatible: still supports root-level parameters (`http_port`, `protocol_policy`, etc.)
  - Consistent with `s3_origin_config` pattern
  - Updated all examples to use new `custom_origin_config` structure
- **Policy lifecycle management**
  - Added `lifecycle { create_before_destroy = true }` to all policy resources (cache, origin request, response headers)
  - Enables single-apply policy deletion instead of requiring two applies
  - Prevents "policy still attached" errors when modifying policies
- **Policy defaults improved**
  - Cache policy now defaults to AWS Managed `Managed-CachingOptimized` instead of hardcoded ID
  - Uses `data.aws_cloudfront_cache_policy` data source for cleaner implementation
  - Origin request policy defaults to `null` (no policy) for optimal static asset delivery
  - Response headers policy defaults to `null` (no policy)

### Added
- 3 new validation checks for monitoring configuration (SNS ARN format, threshold range, evaluation periods)
- New example: `examples/monitoring-config/` demonstrating per-distribution monitoring setup

### Fixed
- CloudWatch monitoring resources now correctly use `us-east-1` provider (CloudFront metrics are region-specific)
- **Behavior sorting regression in manual mode**
  - Fixed crash when `behavior_sorting: manual` and optional attributes (cache_policy_name, response_headers_policy_name, etc.) were commented in YAML
  - Fixed duplicate behaviors appearing across all distributions in manual mode
  - Added proper distribution name filtering in `manual_behaviors_by_dist`
  - Simplified behavior flattening logic to only include essential attributes initially
- **CORS configuration drift**
  - Made `access_control_expose_headers` block dynamic in response headers policies
  - Only created when `expose_headers` list is not empty
  - Prevents Terraform drift on every apply

---
## [1.0.3] - 2026-01-03

### Added
- **Trusted Key Groups support** for CloudFront signed URLs and signed cookies
  - Enable private content access control with public/private key cryptography
  - Configure key groups and public keys via YAML (`trusted-key-groups/trusted-key-groups.yaml`)
  - Support both inline public keys and file-based public keys
  - Lazy loading: only creates key groups that are referenced in distributions
  - Reference key groups by name in behaviors: `trusted_key_group_name: video-streaming`
  - Complete example in `examples/signed-urls/` with testing script
  - New variable: `trusted_key_groups_path` (default: `./trusted-key-groups`)
  - New outputs: `trusted_key_group_ids` and `public_key_ids`
  - 3 new validation checks ensuring key group configuration integrity
  - Complete documentation in README.md and example README

- **Automatic cache invalidation** for CloudFront distributions
  - Simple boolean flag per behavior: `cache_invalidation: true`
  - Invalidates on every `terraform apply` when enabled
  - Default behavior invalidates `/*`, ordered behaviors invalidate their `path_pattern`
  - Uses AWS CLI `create-invalidation` command via `null_resource`
  - Requires AWS CLI >= 2.0
  - No complex change detection needed - intentionally simple for reliability

- **Resource protection documentation**
  - how to protect resources from accidental deletion using IAM permissions

### Changed
- **File rename**: `validations.tf` → `checks.tf`
  - Better reflects Terraform 1.12+ native check blocks
  - All validation logic remains identical
  - No functional changes


---
## [1.0.2] - 2025-12-29

### Removed
- **BREAKING: Removed obsolete variables** `create_route53_records` and `route53_zones`
  - DNS record creation is now fully controlled by the YAML `create_dns_records` parameter per distribution
  - Route53 zones are automatically detected using `data.aws_route53_zone` based on alias domain names
  - Simplifies configuration and reduces confusion
  - Migration: Remove these variables from module calls and use `create_dns_records` in distribution YAML files instead


---
## [1.0.1] - 2025-12-28

### Added
- **Origin Groups support** for automatic failover between primary and secondary origins
  - Configure failover based on HTTP status codes (403, 404, 500, 502, 503, 504)
  - Support for S3-to-S3 and custom origin failover
  - Multiple origin groups per distribution
  - Complete documentation in `docs/ORIGIN_GROUPS.md`
  - Example configuration in `examples/origin-groups/`
  - 8 new test cases covering all validations

### Fixed
- **Lambda@Edge associations** were documented but not implemented in code
  - Added missing `lambda_function_association` dynamic blocks to distributions.tf
  - Now supports viewer-request, viewer-response, origin-request, and origin-response events
  - Updated `docs/LAMBDA_EDGE.md` with correct YAML syntax

### Changed
- **Module variables now have default values** for better developer experience
  - `distributions_path` defaults to `"./distributions"`
  - `policies_path` defaults to `"./policies"`
  - `functions_path` defaults to `"./functions"`
  - `key_value_stores_path` defaults to `"./key-value-stores"`
  - All paths can still be overridden when calling the module
  - Examples simplified (no need to specify paths if using standard structure)

### Improved
- Enhanced validation for behaviors to support both origin IDs and origin group IDs
- Examples now include `providers` block for correct `us-east-1` alias configuration
- Cleaner example structure without unnecessary empty directories


---
## [1.0.0] - 2025-12-24

### Added

#### Core Features
- Multi-distribution CloudFront management with YAML configurations
- Automatic cache behavior sorting based on path pattern specificity (unique feature not found in other Terraform CloudFront modules)
- Support for multiple origins (S3 and Custom)
- Automatic Origin Access Control (OAC) creation for S3 origins
- CloudFront Functions support
- Custom error responses configuration
- SSL/TLS certificate management with ACM
- Geographic restrictions support
- CloudFront logging configuration with S3 bucket policy management
- WAF Web ACL integration

#### Policies Support
- Custom Cache Policies creation
- Custom Origin Request Policies creation
- Custom Response Headers Policies creation
- Full support for AWS Managed Policies via IDs
- Security headers policies (HSTS, CSP, X-Frame-Options, etc.)
- CORS policies configuration

#### Automation Features
- Automatic Route53 records creation with IPv4 and IPv6 support
- CloudWatch monitoring with automatic alarms creation
- CloudWatch dashboard generation
- Error rate monitoring (4xx and 5xx)
- Data transfer metrics

#### Developer Experience
- Resource naming with prefix/suffix support
- Automatic default tags (ManagedBy, Module, ModuleVersion)
- Comprehensive documentation

### Documentation
- Complete README with usage examples
- BEHAVIORS.md explaining cache behavior sorting logic
- AWS Managed Policies reference guide
- Contributing guidelines
- MIT License

### Examples
- Simple example for quick start
- Multi Environment example dev, staging and production (see README.md)

### Infrastructure
- Support for Origin Shield
- Connection attempts and timeout configuration
- Multiple certificate configurations
- IPv6 support toggle


[1.0.3]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/1.0.3
[1.0.2]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/1.0.2
[1.0.1]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/1.0.1
[1.0.0]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/1.0.0
