# CloudFront Module - Automated Tests

This directory contains automated tests for the CloudFront Terraform module using the [Terraform Test Framework](https://developer.hashicorp.com/terraform/language/tests) (available since Terraform v1.7+).

## Test Structure

```
tests/
├── README.md                          # This file
├── basic-distribution.tftest.hcl      # Tests for basic distribution features
└── fixtures/                          # Test fixtures (YAML configurations)
    ├── test-case-01/                  # Simple S3 distribution
    ├── test-case-03/                  # Multiple distributions
    ├── test-case-04/                  # Price classes
    ├── test-case-05/                  # IPv6 support
    ├── test-case-07/                  # Custom default root object
    └── test-case-08/                  # Distribution comments
    ...
```

## Running Tests

### Run all tests

```bash
cd terraform-aws-cloudfront
terraform test
```

### Run tests with verbose output

```bash
terraform test -verbose
```

### Run a specific test file

```bash
terraform test -filter=tests/basic-distribution.tftest.hcl
```

## Test Cases Implemented

Based on [test.csv](../../test.csv), the following test cases are currently implemented:

### Basic Distribution Tests (basic-distribution.tftest.hcl)

| Test Case | Description | Status |
|-----------|-------------|--------|
| #1 | Create simple distribution with S3 origin | ✔️ Implemented |
| #3 | Create multiple distributions from separate YAML files | ✔️ Implemented |
| #4 | Test PriceClass_All, PriceClass_200, PriceClass_100 | ✔️ Implemented |
| #5 | Enable/disable ipv6_enabled | ✔️ Implemented |
| #7 | Set custom default_root_object | ✔️ Implemented |
| #8 | Add distribution comment | ✔️ Implemented |

## Current Limitations

The current test implementation uses `command = plan` which validates that the Terraform configuration is valid and can generate a plan. However, there are some limitations:

1. **Resource Assertions**: Direct resource assertions (e.g., `aws_cloudfront_distribution.this`) don't work with `command = plan` because resources aren't created yet.

2. **Mock Providers**: Tests use mock AWS providers, so no real AWS credentials are required.

3. **Plan-Only Validation**: Tests validate configuration correctness but don't verify actual AWS resource creation.

## Next Steps for Full Test Coverage

To achieve complete test coverage based on test.csv (101 test cases), the following test files should be created:

### Aliases and Certificates
- `aliases.tftest.hcl` - Tests for CNAME aliases, ACM certificates, TLS versions

### Origins
- `origins.tftest.hcl` - Tests for S3 origins, custom origins, OAC, Origin Shield, connection settings

### Behaviors
- `behaviors.tftest.hcl` - Tests for cache behaviors, path patterns, viewer protocol policies

### Policies
- `policies.tftest.hcl` - Tests for cache policies, origin request policies, response headers policies

### Functions and KVS
- `functions.tftest.hcl` - Tests for CloudFront Functions and Key Value Stores

### Security
- `security.tftest.hcl` - Tests for WAF integration, geo restrictions

### DNS and Logging
- `dns.tftest.hcl` - Tests for Route53 integration
- `logging.tftest.hcl` - Tests for CloudFront access logs

### Validation
- `validation.tftest.hcl` - Tests for input validation checks

### Operations
- `operations.tftest.hcl` - Tests for updates, destroys, state management

## Alternative: Integration Tests with Real AWS

For more comprehensive testing that verifies actual AWS resource creation, consider:

1. **Using `command = apply`** with a dedicated test AWS account
2. **Lifecycle Management**: Include teardown logic to clean up resources
3. **AWS Credentials**: Configure AWS credentials for the test account
4. **Cost Awareness**: Be mindful of AWS costs during testing

Example:

```hcl
run "create_and_verify_distribution" {
  command = apply

  variables {
    # ... test variables ...
  }

  assert {
    condition     = output.distribution_domain_names != null
    error_message = "Distribution should be created with domain name"
  }
}
```

## Contributing

When adding new test cases:

1. Create fixture YAML files in `tests/fixtures/test-case-XX/`
2. Add test run blocks to appropriate `.tftest.hcl` file
3. Update this README with the new test case
4. Reference the corresponding row in [test.csv](../../test.csv)

## Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Mock Providers](https://developer.hashicorp.com/terraform/language/tests/mocking)
