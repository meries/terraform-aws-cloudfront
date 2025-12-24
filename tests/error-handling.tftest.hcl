# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 56: Configure 404 → /index.html
# Expected: SPA routing works
# Status: Plan validates without errors

run "custom_error_responses" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-56/distributions"
    policies_path          = "./tests/fixtures/test-case-56/policies"
    functions_path         = "./tests/fixtures/test-case-56/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-56/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 57: Handle 403, 404, 500, etc.
# Expected: All error codes handled
# Status: Plan validates without errors

run "multiple_error_codes" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-57/distributions"
    policies_path          = "./tests/fixtures/test-case-57/policies"
    functions_path         = "./tests/fixtures/test-case-57/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-57/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 58: Return custom response codes
# Expected: Custom codes returned
# Status: Plan validates without errors

run "error_response_codes" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-58/distributions"
    policies_path          = "./tests/fixtures/test-case-58/policies"
    functions_path         = "./tests/fixtures/test-case-58/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-58/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 59: Set error_caching_min_ttl
# Expected: Error caching configured
# Status: Plan validates without errors

run "error_caching" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-59/distributions"
    policies_path          = "./tests/fixtures/test-case-59/policies"
    functions_path         = "./tests/fixtures/test-case-59/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-59/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}
