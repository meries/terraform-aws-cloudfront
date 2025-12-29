# Mock provider configuration for tests (no real AWS credentials needed for plan tests)
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

# Test Case 1: Create simple distribution with S3 origin
# Expected: Distribution created successfully
# Status: Plan validates without errors

run "create_simple_s3_distribution" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-01/distributions"
    policies_path          = "./tests/fixtures/test-case-01/policies"
    functions_path         = "./tests/fixtures/test-case-01/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-01/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "01-simple-s3-distribution"
    }
  }

  # With command = plan, we just verify the plan succeeds
  # No errors means the configuration is valid
}

# Test Case 3: Create multiple distributions from separate YAML files
# Expected: All distributions created
# Status: Plan validates without errors

run "create_multiple_distributions" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-03/distributions"
    policies_path          = "./tests/fixtures/test-case-03/policies"
    functions_path         = "./tests/fixtures/test-case-03/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-03/key-value-stores"
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "03-multiple-distributions"
    }
  }
}

# Test Case 4: Test different price classes
# Expected: All price classes work
# Status: Plan validates without errors

run "test_price_classes" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-04/distributions"
    policies_path          = "./tests/fixtures/test-case-04/policies"
    functions_path         = "./tests/fixtures/test-case-04/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-04/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 5: Enable/disable IPv6
# Expected: IPv6 configuration applied
# Status: Plan validates without errors

run "test_ipv6_support" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-05/distributions"
    policies_path          = "./tests/fixtures/test-case-05/policies"
    functions_path         = "./tests/fixtures/test-case-05/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-05/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 7: Set custom default_root_object
# Expected: Custom root object set
# Status: Plan validates without errors

run "test_default_root_object" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-07/distributions"
    policies_path          = "./tests/fixtures/test-case-07/policies"
    functions_path         = "./tests/fixtures/test-case-07/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-07/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 8: Add distribution comment
# Expected: Comment visible in AWS
# Status: Plan validates without errors

run "test_distribution_comment" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-08/distributions"
    policies_path          = "./tests/fixtures/test-case-08/policies"
    functions_path         = "./tests/fixtures/test-case-08/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-08/key-value-stores"
    create_log_buckets     = false
  }
}

# NOTE: Validation tests (negative tests) with expect_failures
# will be implemented in a separate validation.tftest.hcl file
