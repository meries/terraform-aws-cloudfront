# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 6: Test http2, http2and3, http3
# Expected: HTTP version configured
# Status: Plan validates without errors

run "http_versions" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-06/distributions"
    policies_path          = "./tests/fixtures/test-case-06/policies"
    functions_path         = "./tests/fixtures/test-case-06/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-06/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "06-http-versions"
    }
  }
}
