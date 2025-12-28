# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.1]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/v1.0.1
[1.0.0]: https://github.com/meries/terraform-aws-cloudfront/releases/tag/v1.0.0
