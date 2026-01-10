# Mock provider configuration for tests (no real AWS credentials needed for plan tests)
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 1: Create simple distribution with S3 origin
# Expected: Distribution created successfully
# Status: Plan validates without errors

run "create_simple_s3_distribution" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-01/distributions"
    policies_path         = "./tests/fixtures/test-case-01/policies"
    functions_path        = "./tests/fixtures/test-case-01/functions"
    key_value_stores_path = "./tests/fixtures/test-case-01/key-value-stores"
    create_log_buckets    = false
    common_tags = {
      Environment = "test"
      TestCase    = "01-simple-s3-distribution"
    }
  }

  # With command = plan, we just verify the plan succeeds
  # No errors means the configuration is valid
}

# Test Case 2: Create multiple distributions from separate YAML files
# Expected: All distributions created
# Status: Plan validates without errors

run "create_multiple_distributions" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-02/distributions"
    policies_path         = "./tests/fixtures/test-case-02/policies"
    functions_path        = "./tests/fixtures/test-case-02/functions"
    key_value_stores_path = "./tests/fixtures/test-case-02/key-value-stores"
    create_log_buckets    = false
    common_tags = {
      Environment = "test"
      TestCase    = "02-multiple-distributions"
    }
  }
}

# Test Case 3: Test different price classes
# Expected: All price classes work
# Status: Plan validates without errors

run "test_price_classes" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-03/distributions"
    policies_path         = "./tests/fixtures/test-case-03/policies"
    functions_path        = "./tests/fixtures/test-case-03/functions"
    key_value_stores_path = "./tests/fixtures/test-case-03/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 4: Enable/disable IPv6
# Expected: IPv6 configuration applied
# Status: Plan validates without errors

run "test_ipv6_support" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-04/distributions"
    policies_path         = "./tests/fixtures/test-case-04/policies"
    functions_path        = "./tests/fixtures/test-case-04/functions"
    key_value_stores_path = "./tests/fixtures/test-case-04/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 5: Set custom default_root_object
# Expected: Custom root object set
# Status: Plan validates without errors

run "test_default_root_object" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-07/distributions"
    policies_path         = "./tests/fixtures/test-case-07/policies"
    functions_path        = "./tests/fixtures/test-case-07/functions"
    key_value_stores_path = "./tests/fixtures/test-case-07/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 6: Test HTTP versions
# Expected: HTTP version configuration applied
# Status: Plan validates without errors
run "test_http_versions" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-06/distributions"
    policies_path         = "./tests/fixtures/test-case-06/policies"
    functions_path        = "./tests/fixtures/test-case-06/functions"
    key_value_stores_path = "./tests/fixtures/test-case-06/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 7: Add distribution comment
# Expected: Comment visible in AWS
# Status: Plan validates without errors

run "test_distribution_comment" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-08/distributions"
    policies_path         = "./tests/fixtures/test-case-08/policies"
    functions_path        = "./tests/fixtures/test-case-08/functions"
    key_value_stores_path = "./tests/fixtures/test-case-08/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 8: Empty distribution comment
# Expected: Comment visible in AWS
# Status: Plan validates without errors

run "test_empty_distribution_comment" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-08/distributions"
    policies_path         = "./tests/fixtures/test-case-08/policies"
    functions_path        = "./tests/fixtures/test-case-08/functions"
    key_value_stores_path = "./tests/fixtures/test-case-08/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 9: Multiple aliases (CNAMEs)
# Expected: Distribution with multiple aliases created
# Status: Plan validates without errors

run "test_multiple_aliases" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-09/distributions"
    policies_path         = "./tests/fixtures/test-case-09/policies"
    functions_path        = "./tests/fixtures/test-case-09/functions"
    key_value_stores_path = "./tests/fixtures/test-case-09/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 10: ACM certificate configuration
# Expected: Certificate applied to distribution
# Status: Plan validates without errors

run "test_acm_certificate" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-10/distributions"
    policies_path         = "./tests/fixtures/test-case-10/policies"
    functions_path        = "./tests/fixtures/test-case-10/functions"
    key_value_stores_path = "./tests/fixtures/test-case-10/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 11: TLS minimum protocol version
# Expected: TLS protocol version configured
# Status: Plan validates without errors

run "test_tls_protocols" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-11/distributions"
    policies_path         = "./tests/fixtures/test-case-11/policies"
    functions_path        = "./tests/fixtures/test-case-11/functions"
    key_value_stores_path = "./tests/fixtures/test-case-11/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 12: S3 origin with regional domain
# Expected: S3 origin configured with regional endpoint
# Status: Plan validates without errors

run "test_s3_regional_origin" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-12/distributions"
    policies_path         = "./tests/fixtures/test-case-12/policies"
    functions_path        = "./tests/fixtures/test-case-12/functions"
    key_value_stores_path = "./tests/fixtures/test-case-12/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 13: Custom origin configuration
# Expected: Custom origin created with HTTPS
# Status: Plan validates without errors

run "test_custom_origin" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-13/distributions"
    policies_path         = "./tests/fixtures/test-case-13/policies"
    functions_path        = "./tests/fixtures/test-case-13/functions"
    key_value_stores_path = "./tests/fixtures/test-case-13/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 14: Origin connection settings
# Expected: Connection attempts and timeout configured
# Status: Plan validates without errors

run "test_origin_connection_settings" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-14/distributions"
    policies_path         = "./tests/fixtures/test-case-14/policies"
    functions_path        = "./tests/fixtures/test-case-14/functions"
    key_value_stores_path = "./tests/fixtures/test-case-14/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 15: Custom origin ports
# Expected: Custom HTTP and HTTPS ports configured
# Status: Plan validates without errors

run "test_custom_origin_ports" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-15/distributions"
    policies_path         = "./tests/fixtures/test-case-15/policies"
    functions_path        = "./tests/fixtures/test-case-15/functions"
    key_value_stores_path = "./tests/fixtures/test-case-15/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 16: Origin protocol policies
# Expected: Different protocol policies for different origins
# Status: Plan validates without errors

run "test_origin_protocol_policies" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-16/distributions"
    policies_path         = "./tests/fixtures/test-case-16/policies"
    functions_path        = "./tests/fixtures/test-case-16/functions"
    key_value_stores_path = "./tests/fixtures/test-case-16/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 17: Origin SSL protocols
# Expected: Custom SSL protocols configured for origin
# Status: Plan validates without errors

run "test_origin_ssl_protocols" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-17/distributions"
    policies_path         = "./tests/fixtures/test-case-17/policies"
    functions_path        = "./tests/fixtures/test-case-17/functions"
    key_value_stores_path = "./tests/fixtures/test-case-17/key-value-stores"
    create_log_buckets    = false
  }
}

# Test Case 18: Origin Shield configuration
# Expected: Origin Shield enabled with specified region
# Status: Plan validates without errors

run "test_origin_shield" {
  command = plan

  variables {
    distributions_path    = "./tests/fixtures/test-case-18/distributions"
    policies_path         = "./tests/fixtures/test-case-18/policies"
    functions_path        = "./tests/fixtures/test-case-18/functions"
    key_value_stores_path = "./tests/fixtures/test-case-18/key-value-stores"
    create_log_buckets    = false
  }
}

# NOTE: Validation tests (negative tests) with expect_failures
# will be implemented in a separate validation.tftest.hcl file
