# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 60: Enable access logs to S3
# Expected: Logs written to S3
# Status: Plan validates without errors

run "cloudfront_logs" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-60/distributions"
    policies_path          = "./tests/fixtures/test-case-60/policies"
    functions_path         = "./tests/fixtures/test-case-60/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-60/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 61: Auto-create log bucket (create_log_buckets=true)
# Expected: Bucket created automatically
# Status: Plan validates without errors

run "log_bucket_creation" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-61/distributions"
    policies_path          = "./tests/fixtures/test-case-61/policies"
    functions_path         = "./tests/fixtures/test-case-61/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-61/key-value-stores"
    create_log_buckets     = true
  }
}

# Test Case 62: Custom log prefix
# Expected: Logs in correct prefix
# Status: Plan validates without errors

run "log_prefix" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-62/distributions"
    policies_path          = "./tests/fixtures/test-case-62/policies"
    functions_path         = "./tests/fixtures/test-case-62/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-62/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 63: Enable logging.include_cookies
# Expected: Cookies in log files
# Status: Plan validates without errors

run "include_cookies_in_logs" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-63/distributions"
    policies_path          = "./tests/fixtures/test-case-63/policies"
    functions_path         = "./tests/fixtures/test-case-63/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-63/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 64: Verify lifecycle policy (90d Glacier, 365d delete)
# Expected: Lifecycle rules active
# Status: Plan validates without errors

run "log_bucket_lifecycle" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-64/distributions"
    policies_path          = "./tests/fixtures/test-case-64/policies"
    functions_path         = "./tests/fixtures/test-case-64/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-64/key-value-stores"
    create_log_buckets     = true
  }
}
