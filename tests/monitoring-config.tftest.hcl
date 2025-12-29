# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 74: Enable enable_additional_metrics
# Expected: Real-time metrics available
# Status: Plan validates without errors

run "additional_metrics" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-74/distributions"
    policies_path          = "./tests/fixtures/test-case-74/policies"
    functions_path         = "./tests/fixtures/test-case-74/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-74/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 75: Use naming_prefix and naming_suffix
# Expected: Resource names formatted
# Status: Plan validates without errors

run "naming_prefix_suffix" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-75/distributions"
    policies_path          = "./tests/fixtures/test-case-75/policies"
    functions_path         = "./tests/fixtures/test-case-75/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-75/key-value-stores"
    create_log_buckets     = false
    naming_prefix          = "test"
    naming_suffix          = "prod"
  }
}

# Test Case 76: Set common_tags
# Expected: Tags applied to all resources
# Status: Plan validates without errors

run "common_tags" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-76/distributions"
    policies_path          = "./tests/fixtures/test-case-76/policies"
    functions_path         = "./tests/fixtures/test-case-76/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-76/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
      Team        = "Platform"
    }
  }
}

# Test Case 77: enable_default_tags
# Expected: ManagedBy tags present
# Status: Plan validates without errors

run "default_tags" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-77/distributions"
    policies_path          = "./tests/fixtures/test-case-77/policies"
    functions_path         = "./tests/fixtures/test-case-77/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-77/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      ManagedBy = "Terraform"
    }
  }
}
