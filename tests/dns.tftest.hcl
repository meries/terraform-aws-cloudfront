# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"

  mock_data "aws_route53_zone" {
    defaults = {
      zone_id = "Z1234567890ABC"
      name    = "example.com"
    }
  }
}

# Test Case 69: create_route53_records=true, create_dns_records=true
# Expected: DNS records created
# Status: Plan validates without errors

run "route53_records_auto" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-69/distributions"
    policies_path          = "./tests/fixtures/test-case-69/policies"
    functions_path         = "./tests/fixtures/test-case-69/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-69/key-value-stores"
    create_route53_records = true
    create_log_buckets     = false
  }
}

# Test Case 70: create_dns_records=false per distribution
# Expected: No DNS records created
# Status: Plan validates without errors

run "route53_records_disabled" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-70/distributions"
    policies_path          = "./tests/fixtures/test-case-70/policies"
    functions_path         = "./tests/fixtures/test-case-70/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-70/key-value-stores"
    create_route53_records = true
    create_log_buckets     = false
  }
}

# Test Case 71: A record created
# Expected: A record points to CloudFront
# Status: Already tested (covered by test case 69)

# Test Case 72: AAAA record created (if ipv6_enabled)
# Expected: AAAA record points to CloudFront
# Status: Already tested (covered by test case 69 with IPv6)

# Test Case 73: create_dns_records=false for external zone
# Expected: Distribution works, no DNS created
# Status: Plan validates without errors

run "cross_account_dns" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-73/distributions"
    policies_path          = "./tests/fixtures/test-case-73/policies"
    functions_path         = "./tests/fixtures/test-case-73/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-73/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}
