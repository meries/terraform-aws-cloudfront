# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 49: Create simple viewer-request function
# Expected: Function created and published
# Status: Plan validates without errors

run "cloudfront_function" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-49/distributions"
    policies_path          = "./tests/fixtures/test-case-49/policies"
    functions_path         = "./tests/fixtures/test-case-49/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-49/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 50: Test cloudfront-js-1.0 and cloudfront-js-2.0
# Expected: Both runtimes work
# Status: Plan validates without errors

run "function_runtime" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-50/distributions"
    policies_path          = "./tests/fixtures/test-case-50/policies"
    functions_path         = "./tests/fixtures/test-case-50/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-50/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 51: Attach function to behavior
# Expected: Function executes on requests
# Status: Plan validates without errors

run "function_association" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-51/distributions"
    policies_path          = "./tests/fixtures/test-case-51/policies"
    functions_path         = "./tests/fixtures/test-case-51/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-51/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 52: Test viewer-request, viewer-response
# Expected: Functions trigger correctly
# Status: Plan validates without errors

run "function_events" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-52/distributions"
    policies_path          = "./tests/fixtures/test-case-52/policies"
    functions_path         = "./tests/fixtures/test-case-52/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-52/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}
