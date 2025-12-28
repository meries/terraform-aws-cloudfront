locals {

  # Load distributions (supports recursive loading: **/*.yaml)
  distribution_files = fileset(var.distributions_path, "**/*.yaml")
  distributions = {
    for file in local.distribution_files :
    trimsuffix(basename(file), ".yaml") => yamldecode(file("${var.distributions_path}/${file}"))
  }

  # Load policies (all available policies from YAML files)
  # These contain ALL policies defined in YAML, whether they are used or not
  all_cache_policies            = try(yamldecode(file("${var.policies_path}/cache-policies.yaml")), {})
  all_origin_request_policies   = try(yamldecode(file("${var.policies_path}/origin-request-policies.yaml")), {})
  all_response_headers_policies = try(yamldecode(file("${var.policies_path}/response-headers-policies.yaml")), {})

  # Collect all policy names used in distributions
  used_cache_policy_names = toset(flatten([
    for dist_name, dist_config in local.distributions : concat(
      # Default behavior cache policy
      try(dist_config.default_behavior.cache_policy_name, null) != null ? [dist_config.default_behavior.cache_policy_name] : [],
      # Ordered behaviors cache policies
      [
        for behavior in try(dist_config.behaviors, []) :
        behavior.cache_policy_name
        if try(behavior.cache_policy_name, null) != null
      ]
    )
  ]))

  used_origin_request_policy_names = toset(flatten([
    for dist_name, dist_config in local.distributions : concat(
      # Default behavior origin request policy
      try(dist_config.default_behavior.origin_request_policy_name, null) != null ? [dist_config.default_behavior.origin_request_policy_name] : [],
      # Ordered behaviors origin request policies
      [
        for behavior in try(dist_config.behaviors, []) :
        behavior.origin_request_policy_name
        if try(behavior.origin_request_policy_name, null) != null
      ]
    )
  ]))

  used_response_headers_policy_names = toset(flatten([
    for dist_name, dist_config in local.distributions : concat(
      # Default behavior response headers policy
      try(dist_config.default_behavior.response_headers_policy_name, null) != null ? [dist_config.default_behavior.response_headers_policy_name] : [],
      # Ordered behaviors response headers policies
      [
        for behavior in try(dist_config.behaviors, []) :
        behavior.response_headers_policy_name
        if try(behavior.response_headers_policy_name, null) != null
      ]
    )
  ]))

  # Filter policies to only create those actually used in distributions
  # This ensures we only create policies that are attached to at least one distribution
  # Unused policies defined in YAML will not be created as AWS resources
  cache_policies = {
    for policy_name, policy_config in local.all_cache_policies :
    policy_name => policy_config
    if contains(local.used_cache_policy_names, policy_name)
  }

  origin_request_policies = {
    for policy_name, policy_config in local.all_origin_request_policies :
    policy_name => policy_config
    if contains(local.used_origin_request_policy_names, policy_name)
  }

  response_headers_policies = {
    for policy_name, policy_config in local.all_response_headers_policies :
    policy_name => policy_config
    if contains(local.used_response_headers_policy_names, policy_name)
  }

  # Load CloudFront Functions (all available functions from YAML file)
  # These contain ALL functions defined in YAML, whether they are used or not
  all_cloudfront_functions = fileexists("${var.functions_path}/cloudfront-functions.yaml") ? yamldecode(file("${var.functions_path}/cloudfront-functions.yaml")) : {}

  # Collect all function names used in distributions
  used_function_names = toset(flatten([
    for dist_name, dist_config in local.distributions : concat(
      # Default behavior function associations
      [
        for func_assoc in try(dist_config.default_behavior.function_associations, []) :
        func_assoc.function_name
        if try(func_assoc.function_name, null) != null
      ],
      # Ordered behaviors function associations
      flatten([
        for behavior in try(dist_config.behaviors, []) : [
          for func_assoc in try(behavior.function_associations, []) :
          func_assoc.function_name
          if try(func_assoc.function_name, null) != null
        ]
      ])
    )
  ]))

  # Filter functions to only create those actually used in distributions
  # This ensures we only create functions that are attached to at least one behavior
  # Unused functions defined in YAML will not be created as AWS resources
  cloudfront_functions = {
    for func_name, func_config in local.all_cloudfront_functions :
    func_name => func_config
    if contains(local.used_function_names, func_name)
  }

  # Load Key Value Stores
  all_key_value_stores = fileexists("${var.key_value_stores_path}/key-value-stores.yaml") ? yamldecode(file("${var.key_value_stores_path}/key-value-stores.yaml")) : {}

  # Collect KVS names referenced by used functions
  used_kvs_names = toset([
    for func_name, func_config in local.cloudfront_functions :
    func_config.key_value_store_name
    if try(func_config.key_value_store_name, null) != null
  ])

  # Filter to only create used KVS
  key_value_stores = {
    for kvs_name, kvs_config in local.all_key_value_stores :
    kvs_name => kvs_config
    if contains(local.used_kvs_names, kvs_name)
  }

  # Default tags
  default_tags = var.enable_default_tags ? {
    ManagedBy     = "Terraform"
    Module        = "terraform-aws-cloudfront"
    ModuleVersion = var.module_version
  } : {}

  # Resource naming
  resource_name = {
    for k, v in local.distributions :
    k => "${var.naming_prefix}${k}${var.naming_suffix}"
  }

  # Flatten origins for OAC
  all_origins = flatten([
    for dist_name, dist_config in local.distributions : [
      for origin in dist_config.origins : {
        dist_name   = dist_name
        origin_id   = origin.id
        origin_type = try(origin.type, "s3")
      }
    ]
  ])

  # Flatten all origin groups from all distributions
  all_origin_groups = flatten([
    for dist_name, dist_config in local.distributions : [
      for group in try(dist_config.origin_groups, []) : {
        dist_name         = dist_name
        group_id          = group.id
        failover_criteria = group.failover_criteria
        members           = group.members
      }
    ]
  ])

  # Flatten all behaviors from all distributions with their distribution name
  all_behaviors = flatten([
    for dist_name, dist_config in local.distributions : [
      for behavior in try(dist_config.behaviors, []) : merge(
        behavior,
        {
          dist_name    = dist_name
          path_pattern = behavior.path_pattern
        }
      )
    ]
  ])

  # Create sortable behaviors with composite keys for proper ordering
  # The sorting key format: <specificity>__<wildcard>__<length>__<path>
  # This ensures behaviors are evaluated in the correct order by CloudFront
  sortable_behaviors = {
    for behavior in local.all_behaviors :
    format(
      "%s__%s__%s__%03d__%s",
      behavior.dist_name,
      # Specificity: default "/" first, then exact paths, then wildcards
      behavior.path_pattern == "/" ? "000000" : (
        can(regex(".*\\*", behavior.path_pattern)) ? "zzzzzz" : (
          startswith(replace(behavior.path_pattern, "^/", ""), ".") ? "000001" :
          startswith(behavior.path_pattern, "/") ? lower(split("/", replace(behavior.path_pattern, "^/", ""))[0]) :
          "000002"
        )
      ),
      # Wildcard indicator: non-wildcard paths come before wildcard paths
      can(regex(".*\\*", behavior.path_pattern)) ? "1" : "0",
      # Length: longer paths are more specific (inverted with 999-)
      behavior.path_pattern == "/" ? 999 : (999 - length(replace(behavior.path_pattern, "*", ""))),
      # Final sort: alphabetically by path pattern
      behavior.path_pattern
    ) => behavior
  }

  # Group sorted behaviors by distribution (auto mode)
  sorted_behaviors_by_dist = {
    for dist_name in keys(local.distributions) :
    dist_name => [
      for key in sort([
        for k in keys(local.sortable_behaviors) :
        k if local.sortable_behaviors[k].dist_name == dist_name
      ]) :
      local.sortable_behaviors[key]
    ]
  }

  # Manual mode: behaviors in the order defined in YAML
  manual_behaviors_by_dist = {
    for dist_name, dist_config in local.distributions :
    dist_name => [
      for behavior in try(dist_config.behaviors, []) :
      merge(behavior, {
        dist_name    = dist_name
        path_pattern = behavior.path_pattern
      })
    ]
  }

  # Final behaviors selection based on sorting mode (configured per distribution in YAML)
  # Default to "auto" if not specified
  final_behaviors_by_dist = {
    for dist_name, dist_config in local.distributions :
    dist_name => try(dist_config.behavior_sorting, "auto") == "auto" ?
    local.sorted_behaviors_by_dist[dist_name] :
    local.manual_behaviors_by_dist[dist_name]
  }

  # Extract unique log buckets from all distributions
  log_buckets = var.create_log_buckets ? toset([
    for dist_name, dist_config in local.distributions :
    replace(try(dist_config.logging.bucket, ""), ".s3.amazonaws.com", "")
    if try(dist_config.logging.bucket, null) != null
  ]) : toset([])

  # Flatten all aliases from all distributions
  all_aliases = flatten([
    for dist_name, dist_config in local.distributions : [
      for alias in try(dist_config.aliases, []) : {
        alias           = alias
        dist_name       = dist_name
        zone_name       = join(".", slice(split(".", alias), 1, length(split(".", alias))))
        distribution_id = aws_cloudfront_distribution.dist[dist_name].id
        domain_name     = aws_cloudfront_distribution.dist[dist_name].domain_name
        hosted_zone_id  = aws_cloudfront_distribution.dist[dist_name].hosted_zone_id
      }
    ]
  ])

  # Create a map for Route53 records
  # Supports per-distribution DNS record control via 'create_dns_records' parameter
  # Automatically detects Route53 zone IDs using data sources based on domain names
  # Falls back to global route53_zones variable if provided for backward compatibility
  route53_records = {
    for item in local.all_aliases :
    item.alias => merge(item, {
      zone_id = try(
        # First, try to get zone_id from data source (automatic detection)
        data.aws_route53_zone.zones[item.zone_name].zone_id,
        # Fallback to global route53_zones variable (backward compatibility)
        var.route53_zones[item.zone_name],
        # If neither exists, this will be null and filtered out
        null
      )
    })
    if try(local.distributions[item.dist_name].create_dns_records, true) &&
    # Check if we can get a zone_id from either data source or variable
    (try(data.aws_route53_zone.zones[item.zone_name].zone_id, null) != null ||
    (var.create_route53_records && contains(keys(var.route53_zones), item.zone_name)))
  }

  # Used by validation.tf for checks
  valid_price_classes                    = ["PriceClass_All", "PriceClass_200", "PriceClass_100"]
  valid_viewer_protocol_policies         = ["allow-all", "https-only", "redirect-to-https"]
  valid_behavior_sorting_modes           = ["auto", "manual"]
  valid_origin_types                     = ["s3", "custom"]
  valid_http_versions                    = ["http1.1", "http2", "http2and3", "http3"]
  valid_ssl_support_methods              = ["sni-only", "vip"]
  valid_minimum_protocol_versions        = ["TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021", "TLSv1.2_2025", "TLSv1.3_2025"]
  valid_origin_protocol_policies         = ["http-only", "https-only", "match-viewer"]
  valid_ip_address_types                 = ["ipv4", "ipv6", "dualstack"]
  valid_geo_restriction_types            = ["none", "whitelist", "blacklist"]
  valid_cookies_behaviors                = ["none", "all", "whitelist", "allExcept"]
  valid_headers_behaviors                = ["none", "whitelist"]
  valid_query_strings_behaviors          = ["none", "all", "whitelist", "allExcept"]
  valid_origin_request_headers_behaviors = ["none", "whitelist", "allViewer", "allViewerAndWhitelistCloudFront", "allExcept"]
  valid_frame_options                    = ["DENY", "SAMEORIGIN"]
  valid_referrer_policies                = ["no-referrer", "no-referrer-when-downgrade", "origin", "origin-when-cross-origin", "same-origin", "strict-origin", "strict-origin-when-cross-origin", "unsafe-url"]
  valid_cors_methods                     = ["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]

}
