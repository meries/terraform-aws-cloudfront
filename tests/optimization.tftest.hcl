# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 95: Define policy not used by any distribution
# Expected: Policy not created (filtered)
# Status: Plan validates without errors

run "policy_unused" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-95/distributions"
    policies_path          = "./tests/fixtures/test-case-95/policies"
    functions_path         = "./tests/fixtures/test-case-95/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-95/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 96: Define function not attached
# Expected: Function created anyway
# Status: Plan validates without errors

run "function_unused" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-96/distributions"
    policies_path          = "./tests/fixtures/test-case-96/policies"
    functions_path         = "./tests/fixtures/test-case-96/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-96/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 97: Define KVS not referenced by functions
# Expected: KVS not created (filtered)
# Status: Plan validates without errors

run "kvs_unused" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-97/distributions"
    policies_path          = "./tests/fixtures/test-case-97/policies"
    functions_path         = "./tests/fixtures/test-case-97/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-97/key-value-stores"
    create_log_buckets     = false
  }
}
