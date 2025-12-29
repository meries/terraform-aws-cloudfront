# Mock provider configuration for tests
mock_provider "aws" {}

mock_provider "aws" {
  alias = "us_east_1"
}

# Test Case 21: Auto OAC creation for S3 origins
# Expected: OAC created and attached
# Status: Plan validates without errors

run "origin_access_control" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-21/distributions"
    policies_path          = "./tests/fixtures/test-case-21/policies"
    functions_path         = "./tests/fixtures/test-case-21/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-21/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 65: Attach WAFv2 Web ACL
# Expected: WAF rules enforced
# Status: Plan validates without errors

run "waf_integration" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-65/distributions"
    policies_path          = "./tests/fixtures/test-case-65/policies"
    functions_path         = "./tests/fixtures/test-case-65/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-65/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 66: No geo restrictions
# Expected: All countries allowed
# Status: Plan validates without errors

run "geo_restriction_none" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-66/distributions"
    policies_path          = "./tests/fixtures/test-case-66/policies"
    functions_path         = "./tests/fixtures/test-case-66/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-66/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 67: Whitelist specific countries
# Expected: Only listed countries allowed
# Status: Plan validates without errors

run "geo_restriction_whitelist" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-67/distributions"
    policies_path          = "./tests/fixtures/test-case-67/policies"
    functions_path         = "./tests/fixtures/test-case-67/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-67/key-value-stores"
    create_log_buckets     = false
  }
}

# Test Case 68: Blacklist specific countries
# Expected: Listed countries blocked
# Status: Plan validates without errors

run "geo_restriction_blacklist" {
  command = plan

  variables {
    distributions_path     = "./tests/fixtures/test-case-68/distributions"
    policies_path          = "./tests/fixtures/test-case-68/policies"
    functions_path         = "./tests/fixtures/test-case-68/functions"
    key_value_stores_path  = "./tests/fixtures/test-case-68/key-value-stores"
    create_log_buckets     = false
  }
}
