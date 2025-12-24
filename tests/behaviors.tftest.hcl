# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 22: Configure default cache behavior
# Expected: Default behavior set
# Status: Plan validates without errors

run "default_behavior" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-22/distributions"
    policies_path          = "./tests/fixtures/test-case-22/policies"
    functions_path         = "./tests/fixtures/test-case-22/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-22/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "22-default-behavior"
    }
  }
}

# Test Case 23: Add multiple path patterns
# Expected: Behaviors in correct order
# Status: Plan validates without errors

run "ordered_behaviors" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-23/distributions"
    policies_path          = "./tests/fixtures/test-case-23/policies"
    functions_path         = "./tests/fixtures/test-case-23/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-23/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "23-ordered-behaviors"
    }
  }
}

# Test Case 24: Use behavior_sorting: auto
# Expected: Behaviors auto-sorted by specificity
# Status: Plan validates without errors

run "behavior_sorting_auto" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-24/distributions"
    policies_path          = "./tests/fixtures/test-case-24/policies"
    functions_path         = "./tests/fixtures/test-case-24/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-24/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "24-sorting-auto"
    }
  }
}

# Test Case 25: Use behavior_sorting: manual
# Expected: Behaviors keep YAML order
# Status: Plan validates without errors

run "behavior_sorting_manual" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-25/distributions"
    policies_path          = "./tests/fixtures/test-case-25/policies"
    functions_path         = "./tests/fixtures/test-case-25/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-25/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "25-sorting-manual"
    }
  }
}

# Test Case 26: Test allow-all, https-only, redirect-to-https
# Expected: Protocol policy enforced
# Status: Plan validates without errors

run "viewer_protocol_policy" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-26/distributions"
    policies_path          = "./tests/fixtures/test-case-26/policies"
    functions_path         = "./tests/fixtures/test-case-26/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-26/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "26-viewer-protocol"
    }
  }
}

# Test Case 27: Configure GET, POST, PUT, DELETE, etc.
# Expected: Methods configured
# Status: Plan validates without errors

run "allowed_methods" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-27/distributions"
    policies_path          = "./tests/fixtures/test-case-27/policies"
    functions_path         = "./tests/fixtures/test-case-27/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-27/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "27-allowed-methods"
    }
  }
}

# Test Case 28: Set cached_methods subset of allowed_methods
# Expected: Cache methods configured
# Status: Plan validates without errors

run "cached_methods" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-28/distributions"
    policies_path          = "./tests/fixtures/test-case-28/policies"
    functions_path         = "./tests/fixtures/test-case-28/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-28/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "28-cached-methods"
    }
  }
}

# Test Case 29: Enable/disable compress
# Expected: Compression setting applied
# Status: Plan validates without errors

run "compression" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-29/distributions"
    policies_path          = "./tests/fixtures/test-case-29/policies"
    functions_path         = "./tests/fixtures/test-case-29/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-29/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "29-compression"
    }
  }
}
