# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 13: Configure S3 bucket as origin
# Expected: S3 origin created
# Status: Plan validates without errors

run "s3_origin" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-13/distributions"
    policies_path          = "./tests/fixtures/test-case-13/policies"
    functions_path         = "./tests/fixtures/test-case-13/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-13/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "13-s3-origin"
    }
  }
}

# Test Case 14: Configure custom HTTP/HTTPS origin
# Expected: Custom origin created
# Status: Plan validates without errors

run "custom_origin" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-14/distributions"
    policies_path          = "./tests/fixtures/test-case-14/policies"
    functions_path         = "./tests/fixtures/test-case-14/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-14/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "14-custom-origin"
    }
  }
}

# Test Case 15: Set connection_attempts (1-3), connection_timeout (1-10)
# Expected: Connection settings applied
# Status: Plan validates without errors

run "origin_connection_settings" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-15/distributions"
    policies_path          = "./tests/fixtures/test-case-15/policies"
    functions_path         = "./tests/fixtures/test-case-15/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-15/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "15-connection-settings"
    }
  }
}

# Test Case 16: Custom http_port and https_port
# Expected: Custom ports configured
# Status: Plan validates without errors

run "origin_custom_ports" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-16/distributions"
    policies_path          = "./tests/fixtures/test-case-16/policies"
    functions_path         = "./tests/fixtures/test-case-16/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-16/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "16-custom-ports"
    }
  }
}

# Test Case 17: Test http-only, https-only, match-viewer
# Expected: Protocol policy applied
# Status: Plan validates without errors

run "origin_protocol_policy" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-17/distributions"
    policies_path          = "./tests/fixtures/test-case-17/policies"
    functions_path         = "./tests/fixtures/test-case-17/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-17/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "17-protocol-policy"
    }
  }
}

# Test Case 18: Configure TLSv1, TLSv1.1, TLSv1.2
# Expected: SSL protocols configured
# Status: Plan validates without errors

run "origin_ssl_protocols" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-18/distributions"
    policies_path          = "./tests/fixtures/test-case-18/policies"
    functions_path         = "./tests/fixtures/test-case-18/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-18/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "18-ssl-protocols"
    }
  }
}

# Test Case 19: Enable Origin Shield with region
# Expected: Origin Shield active
# Status: Plan validates without errors

run "origin_shield" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-19/distributions"
    policies_path          = "./tests/fixtures/test-case-19/policies"
    functions_path         = "./tests/fixtures/test-case-19/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-19/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "19-origin-shield"
    }
  }
}

# Test Case 20: Distribution with 2+ origins
# Expected: Multiple origins configured
# Status: Plan validates without errors

run "multiple_origins" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-20/distributions"
    policies_path          = "./tests/fixtures/test-case-20/policies"
    functions_path         = "./tests/fixtures/test-case-20/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-20/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
    common_tags = {
      Environment = "test"
      TestCase    = "20-multiple-origins"
    }
  }
}
