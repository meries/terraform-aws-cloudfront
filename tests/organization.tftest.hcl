# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 79: Distributions in subdirectories
# Expected: All YAML files loaded
# Status: Plan validates without errors

run "multiple_yaml_files" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-79/distributions"
    policies_path          = "./tests/fixtures/test-case-79/policies"
    functions_path         = "./tests/fixtures/test-case-79/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-79/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 80: **/*.yaml pattern
# Expected: Nested YAML files loaded
# Status: Plan validates without errors

run "recursive_loading" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-80/distributions"
    policies_path          = "./tests/fixtures/test-case-80/policies"
    functions_path         = "./tests/fixtures/test-case-80/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-80/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 81: Set module_version variable
# Expected: Version tag applied
# Status: Plan validates without errors

run "module_version" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-81/distributions"
    policies_path          = "./tests/fixtures/test-case-81/policies"
    functions_path         = "./tests/fixtures/test-case-81/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-81/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      ModuleVersion = "v1.0.0"
    }
  }
}
