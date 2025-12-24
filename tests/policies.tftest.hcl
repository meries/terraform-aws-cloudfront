# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 30: Create custom cache policy in YAML
# Expected: Policy created
# Status: Plan validates without errors

run "cache_policy_custom" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-30/distributions"
    policies_path          = "./tests/fixtures/test-case-30/policies"
    functions_path         = "./tests/fixtures/test-case-30/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-30/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 31: Use AWS managed policy ID
# Expected: AWS policy attached
# Status: Plan validates without errors

run "cache_policy_aws_managed" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-31/distributions"
    policies_path          = "./tests/fixtures/test-case-31/policies"
    functions_path         = "./tests/fixtures/test-case-31/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-31/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 32: Set min_ttl, default_ttl, max_ttl
# Expected: TTL values configured
# Status: Plan validates without errors

run "cache_ttl_values" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-32/distributions"
    policies_path          = "./tests/fixtures/test-case-32/policies"
    functions_path         = "./tests/fixtures/test-case-32/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-32/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 33: Test none, all, whitelist, allExcept
# Expected: Cookies behavior works
# Status: Plan validates without errors

run "cookies_behavior" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-33/distributions"
    policies_path          = "./tests/fixtures/test-case-33/policies"
    functions_path         = "./tests/fixtures/test-case-33/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-33/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 34: Test none, whitelist
# Expected: Headers behavior works
# Status: Plan validates without errors

run "headers_behavior" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-34/distributions"
    policies_path          = "./tests/fixtures/test-case-34/policies"
    functions_path         = "./tests/fixtures/test-case-34/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-34/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 35: Test none, all, whitelist, allExcept
# Expected: Query strings behavior works
# Status: Plan validates without errors

run "query_strings_behavior" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-35/distributions"
    policies_path          = "./tests/fixtures/test-case-35/policies"
    functions_path         = "./tests/fixtures/test-case-35/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-35/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 36: Enable gzip and brotli
# Expected: Compression enabled
# Status: Plan validates without errors

run "compression_settings" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-36/distributions"
    policies_path          = "./tests/fixtures/test-case-36/policies"
    functions_path         = "./tests/fixtures/test-case-36/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-36/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 37: Create origin request policy
# Expected: Policy created and attached
# Status: Plan validates without errors

run "origin_request_policy" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-37/distributions"
    policies_path          = "./tests/fixtures/test-case-37/policies"
    functions_path         = "./tests/fixtures/test-case-37/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-37/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 38: Test allViewer, whitelist, etc.
# Expected: Headers forwarded correctly
# Status: Plan validates without errors

run "origin_request_headers" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-38/distributions"
    policies_path          = "./tests/fixtures/test-case-38/policies"
    functions_path         = "./tests/fixtures/test-case-38/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-38/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 39: Create security headers policy
# Expected: Headers added to responses
# Status: Plan validates without errors

run "response_headers_policy" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-39/distributions"
    policies_path          = "./tests/fixtures/test-case-39/policies"
    functions_path         = "./tests/fixtures/test-case-39/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-39/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 40: Configure Strict-Transport-Security
# Expected: HSTS header present
# Status: Plan validates without errors

run "hsts_headers" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-40/distributions"
    policies_path          = "./tests/fixtures/test-case-40/policies"
    functions_path         = "./tests/fixtures/test-case-40/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-40/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 41: Configure Content-Security-Policy
# Expected: CSP header present
# Status: Plan validates without errors

run "csp_headers" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-41/distributions"
    policies_path          = "./tests/fixtures/test-case-41/policies"
    functions_path         = "./tests/fixtures/test-case-41/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-41/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 42: Test DENY, SAMEORIGIN
# Expected: X-Frame-Options header present
# Status: Plan validates without errors

run "frame_options" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-42/distributions"
    policies_path          = "./tests/fixtures/test-case-42/policies"
    functions_path         = "./tests/fixtures/test-case-42/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-42/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 43: Configure referrer policy
# Expected: Referrer-Policy header present
# Status: Plan validates without errors

run "referrer_policy" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-43/distributions"
    policies_path          = "./tests/fixtures/test-case-43/policies"
    functions_path         = "./tests/fixtures/test-case-43/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-43/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 44: Enable XSS protection headers
# Expected: X-XSS-Protection header present
# Status: Plan validates without errors

run "xss_protection" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-44/distributions"
    policies_path          = "./tests/fixtures/test-case-44/policies"
    functions_path         = "./tests/fixtures/test-case-44/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-44/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 45: Configure CORS policy
# Expected: CORS headers present
# Status: Plan validates without errors

run "cors_headers" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-45/distributions"
    policies_path          = "./tests/fixtures/test-case-45/policies"
    functions_path         = "./tests/fixtures/test-case-45/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-45/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 46: Set allowed CORS methods
# Expected: Methods validated
# Status: Plan validates without errors

run "cors_methods" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-46/distributions"
    policies_path          = "./tests/fixtures/test-case-46/policies"
    functions_path         = "./tests/fixtures/test-case-46/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-46/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 47: Set allowed origins
# Expected: Origins validated
# Status: Plan validates without errors

run "cors_origins" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-47/distributions"
    policies_path          = "./tests/fixtures/test-case-47/policies"
    functions_path         = "./tests/fixtures/test-case-47/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-47/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}

# Test Case 48: Add custom response headers
# Expected: Custom headers present
# Status: Plan validates without errors

run "custom_headers" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-48/distributions"
    policies_path          = "./tests/fixtures/test-case-48/policies"
    functions_path         = "./tests/fixtures/test-case-48/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-48/key-value-stores"
    create_route53_records = false
    create_log_buckets     = false
  }
}
