# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 53: Create KVS with items
# Expected: KVS created
# Status: Plan validates without errors

run "key_value_store" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-53/distributions"
    policies_path          = "./tests/fixtures/test-case-53/policies"
    functions_path         = "./tests/fixtures/test-case-53/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-53/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 54: Add multiple key-value pairs
# Expected: All items stored
# Status: Plan validates without errors

run "kvs_items" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-54/distributions"
    policies_path          = "./tests/fixtures/test-case-54/policies"
    functions_path         = "./tests/fixtures/test-case-54/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-54/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 55: Function using KVS for redirects
# Expected: Redirects work via KVS
# Status: Plan validates without errors

run "kvs_with_function" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-55/distributions"
    policies_path          = "./tests/fixtures/test-case-55/policies"
    functions_path         = "./tests/fixtures/test-case-55/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-55/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}
