# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test: Basic origin group with S3 failover
# Expected: Origin group created with 2 members
# Status: Plan validates without errors

run "origin_group_basic_s3_failover" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-01/distributions"
    policies_path          = "./tests/fixtures/test-case-og-01/policies"
    functions_path         = "./tests/fixtures/test-case-og-01/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-01/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-01-basic-s3-failover"
    }
  }
}

# Test: Origin group with custom origins
# Expected: Origin group created with custom HTTP origins
# Status: Plan validates without errors

run "origin_group_custom_origins" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-02/distributions"
    policies_path          = "./tests/fixtures/test-case-og-02/policies"
    functions_path         = "./tests/fixtures/test-case-og-02/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-02/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-02-custom-origins"
    }
  }
}

# Test: Multiple origin groups in single distribution
# Expected: Two origin groups created successfully
# Status: Plan validates without errors

run "origin_group_multiple_groups" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-03/distributions"
    policies_path          = "./tests/fixtures/test-case-og-03/policies"
    functions_path         = "./tests/fixtures/test-case-og-03/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-03/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-03-multiple-groups"
    }
  }
}

# Test: Behavior references origin group
# Expected: Behavior can use origin group as target_origin_id
# Status: Plan validates without errors

run "origin_group_behavior_reference" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-04/distributions"
    policies_path          = "./tests/fixtures/test-case-og-04/policies"
    functions_path         = "./tests/fixtures/test-case-og-04/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-04/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-04-behavior-reference"
    }
  }
}

# Test: Distribution without origin groups (backward compatibility)
# Expected: Distribution works without origin_groups field
# Status: Plan validates without errors

run "origin_group_backward_compatibility" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-05/distributions"
    policies_path          = "./tests/fixtures/test-case-og-05/policies"
    functions_path         = "./tests/fixtures/test-case-og-05/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-05/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-05-backward-compatibility"
    }
  }
}

# Test: Member references non-existent origin
# Expected: Validation fails - origin_id must reference existing origin
# Status: Expect failure

run "origin_group_invalid_origin_reference" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-08/distributions"
    policies_path          = "./tests/fixtures/test-case-og-08/policies"
    functions_path         = "./tests/fixtures/test-case-og-08/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-08/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-08-invalid-origin-reference"
    }
  }

  expect_failures = [
    check.origin_group_member_references
  ]
}

# Test: Invalid status code (200 is not allowed)
# Expected: Validation fails - only 403, 404, 500, 502, 503, 504 allowed
# Status: Expect failure

run "origin_group_invalid_status_code" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-09/distributions"
    policies_path          = "./tests/fixtures/test-case-og-09/policies"
    functions_path         = "./tests/fixtures/test-case-og-09/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-09/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-09-invalid-status-code"
    }
  }

  expect_failures = [
    check.origin_group_status_codes
  ]
}

# Test: Duplicate origin group IDs
# Expected: Validation fails - IDs must be unique
# Status: Expect failure

run "origin_group_duplicate_ids" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-og-10/distributions"
    policies_path          = "./tests/fixtures/test-case-og-10/policies"
    functions_path         = "./tests/fixtures/test-case-og-10/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-og-10/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "og-10-duplicate-ids"
    }
  }

  expect_failures = [
    check.origin_group_unique_ids
  ]
}
