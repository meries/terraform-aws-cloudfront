# CloudFront Policies

# Cache Policies
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy
resource "aws_cloudfront_cache_policy" "policy" {
  for_each = local.cache_policies

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  comment = try(each.value.comment, "Cache policy ${each.key}")

  default_ttl = try(each.value.default_ttl, 86400)
  max_ttl     = try(each.value.max_ttl, 31536000)
  min_ttl     = try(each.value.min_ttl, 0)

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = try(each.value.enable_accept_encoding_gzip, true)
    enable_accept_encoding_brotli = try(each.value.enable_accept_encoding_brotli, true)

    cookies_config {
      cookie_behavior = try(each.value.cookies_behavior, "none")

      dynamic "cookies" {
        for_each = try(each.value.cookies_behavior, "none") == "whitelist" ? [1] : []
        content {
          items = try(each.value.cookies, [])
        }
      }
    }

    headers_config {
      header_behavior = try(each.value.headers_behavior, "none")

      dynamic "headers" {
        for_each = try(each.value.headers_behavior, "none") == "whitelist" ? [1] : []
        content {
          items = try(each.value.headers, [])
        }
      }
    }

    query_strings_config {
      query_string_behavior = try(each.value.query_strings_behavior, "none")

      dynamic "query_strings" {
        for_each = try(each.value.query_strings_behavior, "none") == "whitelist" ? [1] : []
        content {
          items = try(each.value.query_strings, [])
        }
      }
    }
  }
}


# Origin Request Policies
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy
resource "aws_cloudfront_origin_request_policy" "policy" {
  for_each = local.origin_request_policies

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  comment = try(each.value.comment, "Origin request policy ${each.key}")

  cookies_config {
    cookie_behavior = try(each.value.cookies_behavior, "none")

    dynamic "cookies" {
      for_each = contains(["whitelist", "all"], try(each.value.cookies_behavior, "none")) && try(each.value.cookies_behavior, "none") == "whitelist" ? [1] : []
      content {
        items = try(each.value.cookies, [])
      }
    }
  }

  headers_config {
    header_behavior = try(each.value.headers_behavior, "none")

    dynamic "headers" {
      for_each = contains(["whitelist", "allViewer", "allViewerAndWhitelistCloudFront"], try(each.value.headers_behavior, "none")) && try(each.value.headers_behavior, "none") == "whitelist" ? [1] : []
      content {
        items = try(each.value.headers, [])
      }
    }
  }

  query_strings_config {
    query_string_behavior = try(each.value.query_strings_behavior, "none")

    dynamic "query_strings" {
      for_each = try(each.value.query_strings_behavior, "none") == "whitelist" ? [1] : []
      content {
        items = try(each.value.query_strings, [])
      }
    }
  }
}


# Response Headers Policies
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy
resource "aws_cloudfront_response_headers_policy" "policy" {
  for_each = local.response_headers_policies

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  comment = try(each.value.comment, "Response headers policy ${each.key}")

  # CORS Configuration
  dynamic "cors_config" {
    for_each = try(each.value.cors_config, null) != null ? [1] : []
    content {
      access_control_allow_credentials = try(each.value.cors_config.allow_credentials, false)

      access_control_allow_headers {
        items = try(each.value.cors_config.allow_headers, ["*"])
      }

      access_control_allow_methods {
        items = try(each.value.cors_config.allow_methods, ["GET", "HEAD", "OPTIONS"])
      }

      access_control_allow_origins {
        items = try(each.value.cors_config.allow_origins, ["*"])
      }

      access_control_expose_headers {
        items = try(each.value.cors_config.expose_headers, [])
      }

      access_control_max_age_sec = try(each.value.cors_config.max_age_sec, 600)
      origin_override            = try(each.value.cors_config.origin_override, true)
    }
  }

  # Security Headers Configuration
  dynamic "security_headers_config" {
    for_each = try(each.value.security_headers, null) != null ? [1] : []
    content {
      # Content Security Policy
      dynamic "content_security_policy" {
        for_each = try(each.value.security_headers.content_security_policy, null) != null ? [1] : []
        content {
          content_security_policy = each.value.security_headers.content_security_policy.value
          override                = try(each.value.security_headers.content_security_policy.override, true)
        }
      }

      # Content Type Options
      dynamic "content_type_options" {
        for_each = try(each.value.security_headers.content_type_options, false) ? [1] : []
        content {
          override = try(each.value.security_headers.content_type_options_override, true)
        }
      }

      # Frame Options
      dynamic "frame_options" {
        for_each = try(each.value.security_headers.frame_options, null) != null ? [1] : []
        content {
          frame_option = each.value.security_headers.frame_options.value
          override     = try(each.value.security_headers.frame_options.override, true)
        }
      }

      # Referrer Policy
      dynamic "referrer_policy" {
        for_each = try(each.value.security_headers.referrer_policy, null) != null ? [1] : []
        content {
          referrer_policy = each.value.security_headers.referrer_policy.value
          override        = try(each.value.security_headers.referrer_policy.override, true)
        }
      }

      # Strict Transport Security
      dynamic "strict_transport_security" {
        for_each = try(each.value.security_headers.strict_transport_security, null) != null ? [1] : []
        content {
          access_control_max_age_sec = each.value.security_headers.strict_transport_security.max_age_sec
          include_subdomains         = try(each.value.security_headers.strict_transport_security.include_subdomains, true)
          preload                    = try(each.value.security_headers.strict_transport_security.preload, true)
          override                   = try(each.value.security_headers.strict_transport_security.override, true)
        }
      }

      # XSS Protection
      dynamic "xss_protection" {
        for_each = try(each.value.security_headers.xss_protection, null) != null ? [1] : []
        content {
          mode_block = try(each.value.security_headers.xss_protection.mode_block, true)
          protection = each.value.security_headers.xss_protection.enabled
          override   = try(each.value.security_headers.xss_protection.override, true)
        }
      }
    }
  }

  # Custom Headers
  dynamic "custom_headers_config" {
    for_each = try(each.value.custom_headers, null) != null ? [1] : []
    content {
      dynamic "items" {
        for_each = each.value.custom_headers
        content {
          header   = items.value.header
          value    = items.value.value
          override = try(items.value.override, true)
        }
      }
    }
  }

  # Server Timing Header
  dynamic "server_timing_headers_config" {
    for_each = try(each.value.server_timing_headers, null) != null ? [1] : []
    content {
      enabled       = each.value.server_timing_headers.enabled
      sampling_rate = try(each.value.server_timing_headers.sampling_rate, 0)
    }
  }
}
