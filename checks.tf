# YAML Configuration Validations
# Using Terraform check blocks to validate user inputs from YAML files

# ============================================================================
#  DISTRIBUTIONS VALIDATIONS
# ============================================================================

# Validation: Price Class
check "price_class_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      contains(local.valid_price_classes, try(dist_config.price_class, "PriceClass_100"))
    ])
    error_message = <<-EOF
      Invalid price_class value detected. Valid options: ${join(", ", local.valid_price_classes)}
      Check your distribution YAML files.
    EOF
  }
}

# Validation: Viewer Protocol Policy
check "viewer_protocol_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      contains(local.valid_viewer_protocol_policies,
      try(dist_config.default_behavior.viewer_protocol_policy, "redirect-to-https"))
    ])
    error_message = <<-EOF
      Invalid viewer_protocol_policy in default_behavior. Valid options: ${join(", ", local.valid_viewer_protocol_policies)}
    EOF
  }
}

# Validation: Behavior Sorting Mode
check "behavior_sorting_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      contains(local.valid_behavior_sorting_modes, try(dist_config.behavior_sorting, "auto"))
    ])
    error_message = <<-EOF
      Invalid behavior_sorting value. Valid options: ${join(", ", local.valid_behavior_sorting_modes)}
    EOF
  }
}

# Validation: Origin Types
check "origin_type_validation" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        contains(local.valid_origin_types, try(origin.type, "s3"))
      ]
    ]))
    error_message = <<-EOF
      Invalid origin type. Valid options: ${join(", ", local.valid_origin_types)}
    EOF
  }
}

# Validation: Certificate ARN format (must be us-east-1)
check "certificate_arn_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.certificate.acm_certificate_arn, null) == null ||
      can(regex("^arn:aws:acm:us-east-1:[0-9]{12}:certificate/", dist_config.certificate.acm_certificate_arn))
    ])
    error_message = "ACM certificates for CloudFront must be in us-east-1 region. ARN format: arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/UUID"
  }
}

# Validation: WAF ACL ARN format (must be WAFv2 us-east-1)
check "waf_acl_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.web_acl_id, null) == null ||
      can(regex("^arn:aws:wafv2:us-east-1:[0-9]{12}:global/webacl/", dist_config.web_acl_id))
    ])
    error_message = "WAF Web ACLs for CloudFront must be WAFv2 in us-east-1. ARN format: arn:aws:wafv2:us-east-1:ACCOUNT_ID:global/webacl/NAME/ID"
  }
}

# Validation: Origins have required fields
check "origin_required_fields" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.id, null) != null && try(origin.domain_name, null) != null
      ]
    ]))
    error_message = "All origins must have 'id' and 'domain_name' fields"
  }
}

# Validation: Behaviors and default behavior must reference valid origins OR origin groups
check "behavior_target_references" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for behavior in concat(
          [dist_config.default_behavior],
          try(dist_config.behaviors, [])
        ) :
        contains(
          concat(
            [for o in dist_config.origins : o.id],
            [for g in try(dist_config.origin_groups, []) : g.id]
          ),
          behavior.target_origin_id
        )
      ]
    ]))
    error_message = "Behavior target_origin_id must reference an existing origin ID or origin group ID"
  }
}

# Validation: enabled is boolean
check "enabled_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.enabled, null) == null || can(tobool(dist_config.enabled))
    ])
    error_message = "'enabled' must be a boolean value (true or false)"
  }
}

# Validation: ipv6_enabled is boolean
check "ipv6_enabled_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.ipv6_enabled, null) == null || can(tobool(dist_config.ipv6_enabled))
    ])
    error_message = "'ipv6_enabled' must be a boolean value (true or false)"
  }
}

# Validation: create_dns_records is boolean
check "create_dns_records_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.create_dns_records, null) == null || can(tobool(dist_config.create_dns_records))
    ])
    error_message = "'create_dns_records' must be a boolean value (true or false)"
  }
}

# Validation: route53_zone_id is string and starts with 'Z' if provided
check "route53_zone_id_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.route53_zone_id, null) == null ||
      (can(tostring(dist_config.route53_zone_id)) && can(regex("^Z[A-Z0-9]+$", dist_config.route53_zone_id)))
    ])
    error_message = "'route53_zone_id' must be a valid Route53 Zone ID (starts with 'Z' followed by alphanumeric characters)"
  }
}

# Validation: enable_additional_metrics is boolean
check "enable_additional_metrics_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.enable_additional_metrics, null) == null || can(tobool(dist_config.enable_additional_metrics))
    ])
    error_message = "'enable_additional_metrics' must be a boolean value (true or false)"
  }
}

# Validation: HTTP version
check "http_version_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.http_version, null) == null ||
      contains(local.valid_http_versions, try(dist_config.http_version, "http2"))
    ])
    error_message = <<-EOF
      Invalid http_version value. Valid options: ${join(", ", local.valid_http_versions)}
    EOF
  }
}

# Validation: Minimum TLS protocol version
check "minimum_protocol_version_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.certificate.minimum_protocol_version, null) == null ||
      contains(local.valid_minimum_protocol_versions, try(dist_config.certificate.minimum_protocol_version, "TLSv1.2_2021"))
    ])
    error_message = <<-EOF
      Invalid certificate.minimum_protocol_version. Valid options: ${join(", ", local.valid_minimum_protocol_versions)}
    EOF
  }
}

# Validation: Origin protocol policy (custom origins)
check "origin_protocol_policy_validation" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.type, "s3") != "custom" ||
        try(origin.protocol_policy, null) == null ||
        contains(local.valid_origin_protocol_policies, try(origin.protocol_policy, "https-only"))
      ]
    ]))
    error_message = <<-EOF
      Invalid origin.protocol_policy for custom origin. Valid options: ${join(", ", local.valid_origin_protocol_policies)}
    EOF
  }
}

# Validation: Origin protocol policy and ports consistency
# http-only should only have http_port, https-only should only have https_port, match-viewer can have both
check "origin_protocol_policy_ports_consistency" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.type, "s3") == "s3" || try(origin.protocol_policy, null) == null || (
          # http-only: only http_port should be explicitly set (https_port should not be set or be default 443)
          (try(origin.protocol_policy, "https-only") == "http-only" &&
          try(origin.https_port, null) == null) ||
          # https-only: only https_port should be explicitly set (http_port should not be set or be default 80)
          (try(origin.protocol_policy, "https-only") == "https-only" &&
          try(origin.http_port, null) == null) ||
          # match-viewer: both ports can be set
          try(origin.protocol_policy, "https-only") == "match-viewer"
        )
      ]
    ]))
    error_message = <<-EOF
      Origin protocol_policy and port configuration mismatch:
      - protocol_policy: "http-only" should only have http_port configured
      - protocol_policy: "https-only" should only have https_port configured
      - protocol_policy: "match-viewer" can have both http_port and https_port configured

      Remove the conflicting port from your origin configuration or change the protocol_policy.
    EOF
  }
}

# Validation: Origin IP address type
check "origin_ip_address_type_validation" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.ip_address_type, null) == null ||
        contains(local.valid_ip_address_types, try(origin.ip_address_type, "ipv4"))
      ]
    ]))
    error_message = <<-EOF
      Invalid origin.ip_address_type. Valid options: ${join(", ", local.valid_ip_address_types)}
      This parameter specifies which IP protocol CloudFront uses when connecting to your origin.
    EOF
  }
}

# Validation: Geo restriction type
check "geo_restriction_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.geo_restriction.type, null) == null ||
      contains(local.valid_geo_restriction_types, try(dist_config.geo_restriction.type, "none"))
    ])
    error_message = <<-EOF
      Invalid geo_restriction.type. Valid options: ${join(", ", local.valid_geo_restriction_types)}
    EOF
  }
}

# Validation: Geo restriction locations when type is whitelist/blacklist
check "geo_restriction_locations_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.geo_restriction.type, "none") == "none" ||
      (length(try(dist_config.geo_restriction.locations, [])) > 0)
    ])
    error_message = "geo_restriction.locations must be specified when geo_restriction.type is 'whitelist' or 'blacklist'"
  }
}

# Validation: Default root object is string
check "default_root_object_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.default_root_object, null) == null || can(tostring(dist_config.default_root_object))
    ])
    error_message = "'default_root_object' must be a string value"
  }
}

# Validation: Aliases is list
check "aliases_type_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.aliases, null) == null || can(tolist(dist_config.aliases))
    ])
    error_message = "'aliases' must be a list of domain names"
  }
}

# Validation: Certificate required when aliases are specified
check "certificate_with_aliases_validation" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      length(try(dist_config.aliases, [])) == 0 ||
      try(dist_config.certificate.acm_certificate_arn, null) != null
    ])
    error_message = "ACM certificate (certificate.acm_certificate_arn) is required when aliases are specified"
  }
}

# Validation: Custom error response codes are valid
check "custom_error_response_codes_validation" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for error_resp in try(dist_config.custom_error_responses, []) :
        contains([400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504], error_resp.error_code)
      ]
    ]))
    error_message = "custom_error_responses error_code must be a valid HTTP error code (400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504)"
  }
}

# ============================================================================
#  POLICIES VALIDATIONS
# ============================================================================

# Validation: Cache policy cookies_behavior
check "cache_policy_cookies_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_cache_policies :
      try(policy_config.cookies_behavior, null) == null ||
      contains(local.valid_cookies_behaviors, policy_config.cookies_behavior)
    ])
    error_message = <<-EOF
      Invalid cookies_behavior in cache policy. Valid options: ${join(", ", local.valid_cookies_behaviors)}
      Check your policies/cache-policies.yaml file.
    EOF
  }
}

# Validation: Cache policy headers_behavior
check "cache_policy_headers_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_cache_policies :
      try(policy_config.headers_behavior, null) == null ||
      contains(local.valid_headers_behaviors, policy_config.headers_behavior)
    ])
    error_message = <<-EOF
      Invalid headers_behavior in cache policy. Valid options: ${join(", ", local.valid_headers_behaviors)}
      Check your policies/cache-policies.yaml file.
    EOF
  }
}

# Validation: Cache policy query_strings_behavior
check "cache_policy_query_strings_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_cache_policies :
      try(policy_config.query_strings_behavior, null) == null ||
      contains(local.valid_query_strings_behaviors, policy_config.query_strings_behavior)
    ])
    error_message = <<-EOF
      Invalid query_strings_behavior in cache policy. Valid options: ${join(", ", local.valid_query_strings_behaviors)}
      Check your policies/cache-policies.yaml file.
    EOF
  }
}

# Validation: Cache policy TTL values
check "cache_policy_ttl_values" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_cache_policies :
      try(policy_config.min_ttl, 0) >= 0 &&
      try(policy_config.default_ttl, 86400) >= try(policy_config.min_ttl, 0) &&
      try(policy_config.max_ttl, 31536000) >= try(policy_config.default_ttl, 86400)
    ])
    error_message = "Cache policy TTL values must satisfy: 0 <= min_ttl <= default_ttl <= max_ttl"
  }
}

# Validation: Cache policy whitelist requires items
check "cache_policy_whitelist_items" {
  assert {
    condition = alltrue(flatten([
      for policy_name, policy_config in local.all_cache_policies : [
        # Cookies whitelist
        try(policy_config.cookies_behavior, "none") != "whitelist" ||
        length(try(policy_config.cookies, [])) > 0,
        # Headers whitelist
        try(policy_config.headers_behavior, "none") != "whitelist" ||
        length(try(policy_config.headers, [])) > 0,
        # Query strings whitelist
        try(policy_config.query_strings_behavior, "none") != "whitelist" ||
        length(try(policy_config.query_strings, [])) > 0
      ]
    ]))
    error_message = "When using 'whitelist' behavior, you must specify the corresponding items (cookies, headers, or query_strings)"
  }
}

# Validation: Origin request policy cookies_behavior
check "origin_request_policy_cookies_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_origin_request_policies :
      try(policy_config.cookies_behavior, null) == null ||
      contains(local.valid_cookies_behaviors, policy_config.cookies_behavior)
    ])
    error_message = <<-EOF
      Invalid cookies_behavior in origin request policy. Valid options: ${join(", ", local.valid_cookies_behaviors)}
      Check your policies/origin-request-policies.yaml file.
    EOF
  }
}

# Validation: Origin request policy headers_behavior
check "origin_request_policy_headers_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_origin_request_policies :
      try(policy_config.headers_behavior, null) == null ||
      contains(local.valid_origin_request_headers_behaviors, policy_config.headers_behavior)
    ])
    error_message = <<-EOF
      Invalid headers_behavior in origin request policy. Valid options: ${join(", ", local.valid_origin_request_headers_behaviors)}
      Check your policies/origin-request-policies.yaml file.
    EOF
  }
}

# Validation: Origin request policy query_strings_behavior
check "origin_request_policy_query_strings_behavior" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_origin_request_policies :
      try(policy_config.query_strings_behavior, null) == null ||
      contains(local.valid_query_strings_behaviors, policy_config.query_strings_behavior)
    ])
    error_message = <<-EOF
      Invalid query_strings_behavior in origin request policy. Valid options: ${join(", ", local.valid_query_strings_behaviors)}
      Check your policies/origin-request-policies.yaml file.
    EOF
  }
}

# Validation: Response headers policy frame_options
check "response_headers_policy_frame_options" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_response_headers_policies :
      try(policy_config.security_headers.frame_options.value, null) == null ||
      contains(local.valid_frame_options, policy_config.security_headers.frame_options.value)
    ])
    error_message = <<-EOF
      Invalid security_headers.frame_options.value. Valid options: ${join(", ", local.valid_frame_options)}
      Check your policies/response-headers-policies.yaml file.
    EOF
  }
}

# Validation: Response headers policy referrer_policy
check "response_headers_policy_referrer_policy" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_response_headers_policies :
      try(policy_config.security_headers.referrer_policy.value, null) == null ||
      contains(local.valid_referrer_policies, policy_config.security_headers.referrer_policy.value)
    ])
    error_message = <<-EOF
      Invalid security_headers.referrer_policy.value. Valid options: ${join(", ", local.valid_referrer_policies)}
      Check your policies/response-headers-policies.yaml file.
    EOF
  }
}

# Validation: Response headers policy CORS methods
check "response_headers_policy_cors_methods" {
  assert {
    condition = alltrue(flatten([
      for policy_name, policy_config in local.all_response_headers_policies : [
        for method in try(policy_config.cors_config.allow_methods, []) :
        contains(local.valid_cors_methods, method)
      ]
    ]))
    error_message = <<-EOF
      Invalid CORS allow_methods. Valid options: ${join(", ", local.valid_cors_methods)}
      Check your policies/response-headers-policies.yaml file.
    EOF
  }
}

# Validation: Response headers policy HSTS max_age
check "response_headers_policy_hsts_max_age" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_response_headers_policies :
      try(policy_config.security_headers.strict_transport_security.max_age_sec, 0) >= 0 &&
      try(policy_config.security_headers.strict_transport_security.max_age_sec, 0) <= 63072000
    ])
    error_message = "security_headers.strict_transport_security.max_age_sec must be between 0 and 63072000 (2 years)"
  }
}

# Validation: Response headers policy CORS max_age
check "response_headers_policy_cors_max_age" {
  assert {
    condition = alltrue([
      for policy_name, policy_config in local.all_response_headers_policies :
      try(policy_config.cors_config.max_age_sec, 0) >= 0 &&
      try(policy_config.cors_config.max_age_sec, 0) <= 86400
    ])
    error_message = "cors_config.max_age_sec must be between 0 and 86400 (24 hours)"
  }
}

# ============================================================================
#  CLOUDFRONT FUNCTIONS VALIDATIONS
# ============================================================================

# Validation: CloudFront Function runtime
check "cloudfront_function_runtime" {
  assert {
    condition = alltrue([
      for func_name, func_config in local.all_cloudfront_functions :
      contains(["cloudfront-js-1.0", "cloudfront-js-2.0"], try(func_config.runtime, "cloudfront-js-2.0"))
    ])
    error_message = <<-EOF
      Invalid CloudFront Function runtime. Valid options: cloudfront-js-1.0, cloudfront-js-2.0
      Check your functions/cloudfront-functions.yaml file.
    EOF
  }
}

# Validation: CloudFront Function publish is boolean
check "cloudfront_function_publish" {
  assert {
    condition = alltrue([
      for func_name, func_config in local.all_cloudfront_functions :
      try(func_config.publish, null) == null || can(tobool(func_config.publish))
    ])
    error_message = "'publish' must be a boolean value in CloudFront Functions"
  }
}

# Validation: CloudFront Function KVS reference exists
check "cloudfront_function_kvs_reference" {
  assert {
    condition = alltrue([
      for func_name, func_config in local.all_cloudfront_functions :
      try(func_config.key_value_store_name, null) == null ||
      contains(keys(local.all_key_value_stores), try(func_config.key_value_store_name, ""))
    ])
    error_message = <<-EOF
      CloudFront Function references a key_value_store_name that doesn't exist in key-value-stores.yaml
      Check your functions/cloudfront-functions.yaml file.
    EOF
  }
}

# ============================================================================
#  KEY VALUE STORES VALIDATIONS
# ============================================================================

# Validation: KVS items have non-empty keys
check "kvs_items_keys" {
  assert {
    condition = alltrue(flatten([
      for kvs_name, kvs_config in local.all_key_value_stores : [
        for item in try(kvs_config.items, []) :
        try(item.key, "") != ""
      ]
    ]))
    error_message = "All Key Value Store items must have non-empty 'key' field"
  }
}

# Validation: KVS items have non-empty values
check "kvs_items_values" {
  assert {
    condition = alltrue(flatten([
      for kvs_name, kvs_config in local.all_key_value_stores : [
        for item in try(kvs_config.items, []) :
        try(item.value, "") != ""
      ]
    ]))
    error_message = "All Key Value Store items must have non-empty 'value' field"
  }
}

# ============================================================================
#  ORIGINS VALIDATIONS
# ============================================================================

# Validation: Origin connection_attempts
check "origin_connection_attempts" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.connection_attempts, 3) >= 1 &&
        try(origin.connection_attempts, 3) <= 3
      ]
    ]))
    error_message = "origin.connection_attempts must be between 1 and 3"
  }
}

# Validation: Origin connection_timeout
check "origin_connection_timeout" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.connection_timeout, 10) >= 1 &&
        try(origin.connection_timeout, 10) <= 10
      ]
    ]))
    error_message = "origin.connection_timeout must be between 1 and 10 seconds"
  }
}

# Validation: Origin http_port
check "origin_http_port" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.http_port, 80) >= 1 &&
        try(origin.http_port, 80) <= 65535
      ]
    ]))
    error_message = "origin.http_port must be between 1 and 65535"
  }
}

# Validation: Origin https_port
check "origin_https_port" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) :
        try(origin.https_port, 443) >= 1 &&
        try(origin.https_port, 443) <= 65535
      ]
    ]))
    error_message = "origin.https_port must be between 1 and 65535"
  }
}

# Validation: Origin ssl_protocols (custom origins)
check "origin_ssl_protocols" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for origin in try(dist_config.origins, []) : flatten([
          for protocol in try(origin.ssl_protocols, []) :
          contains(["TLSv1", "TLSv1.1", "TLSv1.2"], protocol)
        ])
      ]
    ]))
    error_message = "origin.ssl_protocols must contain valid values: TLSv1, TLSv1.1, TLSv1.2"
  }
}

# ============================================================================
#  BEHAVIORS VALIDATIONS
# ============================================================================

# Validation: Behavior allowed_methods
check "behavior_allowed_methods" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : flatten([
        # Default behavior
        [
          for method in try(dist_config.default_behavior.allowed_methods, ["GET", "HEAD"]) :
          contains(local.valid_cors_methods, method)
        ],
        # Ordered behaviors
        flatten([
          for behavior in try(dist_config.behaviors, []) : [
            for method in try(behavior.allowed_methods, ["GET", "HEAD"]) :
            contains(local.valid_cors_methods, method)
          ]
        ])
      ])
    ]))
    error_message = <<-EOF
      Invalid allowed_methods in behavior. Valid options: ${join(", ", local.valid_cors_methods)}
    EOF
  }
}

# Validation: Behavior cached_methods subset of allowed_methods
check "behavior_cached_methods_subset" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : concat(
        # Default behavior
        [
          alltrue([
            for method in try(dist_config.default_behavior.cached_methods, ["GET", "HEAD"]) :
            contains(try(dist_config.default_behavior.allowed_methods, ["GET", "HEAD", "OPTIONS"]), method)
          ])
        ],
        # Ordered behaviors
        [
          for behavior in try(dist_config.behaviors, []) :
          alltrue([
            for method in try(behavior.cached_methods, ["GET", "HEAD"]) :
            contains(try(behavior.allowed_methods, ["GET", "HEAD", "OPTIONS"]), method)
          ])
        ]
      )
    ]))
    error_message = "cached_methods must be a subset of allowed_methods"
  }
}

# Validation: Behavior compress is boolean
check "behavior_compress" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : concat(
        [try(dist_config.default_behavior.compress, null) == null || can(tobool(dist_config.default_behavior.compress))],
        [
          for behavior in try(dist_config.behaviors, []) :
          try(behavior.compress, null) == null || can(tobool(behavior.compress))
        ]
      )
    ]))
    error_message = "'compress' must be a boolean value in behaviors"
  }
}

# Validation: Logging include_cookies is boolean
check "logging_include_cookies" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      try(dist_config.logging.include_cookies, null) == null ||
      can(tobool(dist_config.logging.include_cookies))
    ])
    error_message = "'logging.include_cookies' must be a boolean value"
  }
}

# ========================================
# Origin Groups Validations
# ========================================

# Validation: Origin group must have exactly 2 members
check "origin_group_member_count" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for group in try(dist_config.origin_groups, []) :
        length(group.members) == 2
      ]
    ]))
    error_message = "Origin groups must have exactly 2 members (primary and secondary)"
  }
}

# Validation: Origin group members must reference existing origins
check "origin_group_member_references" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for group in try(dist_config.origin_groups, []) : [
          for member in group.members :
          contains([for o in dist_config.origins : o.id], member.origin_id)
        ]
      ]
    ]))
    error_message = "Origin group members must reference existing origin IDs defined in the distribution"
  }
}

# Validation: Origin group IDs must be unique within distribution
check "origin_group_unique_ids" {
  assert {
    condition = alltrue([
      for dist_name, dist_config in local.distributions :
      length(try(dist_config.origin_groups, [])) == length(distinct([
        for group in try(dist_config.origin_groups, []) : group.id
      ]))
    ])
    error_message = "Origin group IDs must be unique within each distribution"
  }
}

# Validation: Failover status codes must be valid
check "origin_group_status_codes" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : [
        for group in try(dist_config.origin_groups, []) : [
          for code in group.failover_criteria.status_codes :
          contains([403, 404, 500, 502, 503, 504], code)
        ]
      ]
    ]))
    error_message = "Valid failover status codes: 403, 404, 500, 502, 503, 504"
  }
}

# Validation: Cache Invalidation must be boolean
check "cache_invalidation_type" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : concat(
        # Default behavior
        [can(tobool(try(dist_config.default_behavior.cache_invalidation, false)))],
        # Ordered behaviors
        [
          for behavior in try(dist_config.behaviors, []) :
          can(tobool(try(behavior.cache_invalidation, false)))
        ]
      )
    ]))
    error_message = "cache_invalidation must be a boolean (true or false)"
  }
}

# ============================================================================
#  TRUSTED KEY GROUPS VALIDATIONS
# ============================================================================

# Validation: Public keys have required fields (name and encoded_key or encoded_key_file)
check "public_keys_required_fields" {
  assert {
    condition = alltrue(flatten([
      for kg_name, kg_config in local.all_trusted_key_groups : [
        for key in try(kg_config.public_keys, []) :
        try(key.name, null) != null &&
        (try(key.encoded_key, null) != null || try(key.encoded_key_file, null) != null)
      ]
    ]))
    error_message = "All public keys must have 'name' and either 'encoded_key' or 'encoded_key_file' fields"
  }
}

# Validation: Trusted key groups have at least one public key
check "trusted_key_groups_has_keys" {
  assert {
    condition = alltrue([
      for kg_name, kg_config in local.all_trusted_key_groups :
      length(try(kg_config.public_keys, [])) > 0
    ])
    error_message = "Trusted key groups must have at least one public key"
  }
}

# Validation: Trusted key group names referenced in distributions exist
check "trusted_key_group_references" {
  assert {
    condition = alltrue(flatten([
      for dist_name, dist_config in local.distributions : concat(
        # Default behavior
        try(dist_config.default_behavior.trusted_key_group_name, null) != null ?
        [contains(keys(local.all_trusted_key_groups), dist_config.default_behavior.trusted_key_group_name)] : [true],
        # Ordered behaviors
        [
          for behavior in try(dist_config.behaviors, []) :
          try(behavior.trusted_key_group_name, null) != null ?
          contains(keys(local.all_trusted_key_groups), behavior.trusted_key_group_name) : true
        ]
      )
    ]))
    error_message = <<-EOF
      Behavior references a trusted_key_group_name that doesn't exist in trusted-key-groups.yaml
      Check your distribution YAML files and trusted-key-groups/trusted-key-groups.yaml file.
    EOF
  }
}
