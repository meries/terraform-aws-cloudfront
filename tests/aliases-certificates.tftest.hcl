# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 9: Add multiple aliases to distribution
# Expected: Aliases configured
# Status: Plan validates without errors

run "multiple_aliases" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-09/distributions"
    policies_path          = "./tests/fixtures/test-case-09/policies"
    functions_path         = "./tests/fixtures/test-case-09/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-09/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "09-multiple-aliases"
    }
  }
}

# Test Case 10: Attach ACM certificate with aliases
# Expected: Certificate attached, HTTPS works
# Status: Plan validates without errors

run "acm_certificate_with_aliases" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-10/distributions"
    policies_path          = "./tests/fixtures/test-case-10/policies"
    functions_path         = "./tests/fixtures/test-case-10/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-10/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "10-acm-certificate"
    }
  }
}

# Test Case 11: Test TLSv1.2_2021, TLSv1.2_2019
# Expected: Minimum TLS version enforced
# Status: Plan validates without errors

run "certificate_ssl_protocols" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-11/distributions"
    policies_path          = "./tests/fixtures/test-case-11/policies"
    functions_path         = "./tests/fixtures/test-case-11/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-11/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "11-tls-protocols"
    }
  }
}

# Test Case 12: Distribution without aliases (default cert)
# Expected: Default *.cloudfront.net cert used
# Status: Plan validates without errors

run "cloudfront_default_cert" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-12/distributions"
    policies_path          = "./tests/fixtures/test-case-12/policies"
    functions_path         = "./tests/fixtures/test-case-12/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-12/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "12-default-cert"
    }
  }
}
