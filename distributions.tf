# CloudFront Distributions
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "dist" {
  for_each = local.distributions

  enabled             = try(each.value.enabled, true)
  is_ipv6_enabled     = try(each.value.ipv6_enabled, true)
  comment             = try(each.value.comment, each.key)
  default_root_object = try(each.value.default_root_object, "index.html")
  price_class         = try(each.value.price_class, "PriceClass_100")
  aliases             = try(each.value.aliases, [])
  web_acl_id          = try(each.value.web_acl_id, null)

  # Origins
  dynamic "origin" {
    for_each = each.value.origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.id
      origin_path              = try(origin.value.path, "")
      connection_attempts      = try(origin.value.connection_attempts, 3)
      connection_timeout       = try(origin.value.connection_timeout, 10)
      origin_access_control_id = try(origin.value.type, "s3") == "s3" ? aws_cloudfront_origin_access_control.oac["${each.key}-${origin.value.id}"].id : null

      dynamic "origin_shield" {
        for_each = try(origin.value.origin_shield.enabled, false) ? [1] : []
        content {
          enabled              = true
          origin_shield_region = origin.value.origin_shield.region
        }
      }

      dynamic "custom_origin_config" {
        for_each = try(origin.value.type, "s3") == "custom" ? [1] : []
        content {
          http_port                = try(origin.value.http_port, 80)
          https_port               = try(origin.value.https_port, 443)
          origin_protocol_policy   = try(origin.value.protocol_policy, "https-only")
          origin_ssl_protocols     = try(origin.value.ssl_protocols, ["TLSv1.2"])
          origin_keepalive_timeout = try(origin.value.keepalive_timeout, 5)
          origin_read_timeout      = try(origin.value.read_timeout, 30)
          # response_completion_timeout is not yet supported in Terraform AWS provider (even in v6.27)
          # See: https://github.com/hashicorp/terraform-provider-aws/issues/44116
          # Default: null (no timeout enforced if not specified)
          # Must be >= origin_read_timeout when set
          # response_completion_timeout = try(origin.value.response_completion_timeout, null)

          # ip_address_type is not yet supported in Terraform AWS provider (even in v6.27)
          # See: https://github.com/hashicorp/terraform-provider-aws/issues/44479
          # Default: ipv4, Valid values: ipv4, ipv6, dualstack
          # ip_address_type = try(origin.value.ip_address_type, "ipv4")
        }
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = each.value.default_behavior.target_origin_id
    viewer_protocol_policy = try(each.value.default_behavior.viewer_protocol_policy, "redirect-to-https")
    allowed_methods        = try(each.value.default_behavior.allowed_methods, ["GET", "HEAD", "OPTIONS"])
    cached_methods         = try(each.value.default_behavior.cached_methods, ["GET", "HEAD"])
    compress               = try(each.value.default_behavior.compress, true)

    cache_policy_id = try(
      aws_cloudfront_cache_policy.policy[each.value.default_behavior.cache_policy_name].id,
      each.value.default_behavior.cache_policy_id,
      null
    )

    origin_request_policy_id = try(
      aws_cloudfront_origin_request_policy.policy[each.value.default_behavior.origin_request_policy_name].id,
      each.value.default_behavior.origin_request_policy_id,
      null
    )

    response_headers_policy_id = try(
      aws_cloudfront_response_headers_policy.policy[each.value.default_behavior.response_headers_policy_name].id,
      each.value.default_behavior.response_headers_policy_id,
      null
    )

    # CloudFront Functions support
    dynamic "function_association" {
      for_each = try(each.value.default_behavior.function_associations, [])
      content {
        event_type = function_association.value.event_type
        function_arn = try(
          aws_cloudfront_function.function[function_association.value.function_name].arn,
          function_association.value.function_arn
        )
      }
    }

    # Lambda@Edge support
    dynamic "lambda_function_association" {
      for_each = try(each.value.default_behavior.lambda_function_associations, [])
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = try(lambda_function_association.value.include_body, false)
      }
    }
  }

  # Ordered cache behaviors (sorting mode configured per distribution in YAML - see BEHAVIORS.md)
  dynamic "ordered_cache_behavior" {
    for_each = local.final_behaviors_by_dist[each.key]
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = try(ordered_cache_behavior.value.viewer_protocol_policy, "redirect-to-https")
      allowed_methods        = try(ordered_cache_behavior.value.allowed_methods, ["GET", "HEAD", "OPTIONS"])
      cached_methods         = try(ordered_cache_behavior.value.cached_methods, ["GET", "HEAD"])
      compress               = try(ordered_cache_behavior.value.compress, true)

      cache_policy_id = try(
        aws_cloudfront_cache_policy.policy[ordered_cache_behavior.value.cache_policy_name].id,
        ordered_cache_behavior.value.cache_policy_id,
        null
      )

      origin_request_policy_id = try(
        aws_cloudfront_origin_request_policy.policy[ordered_cache_behavior.value.origin_request_policy_name].id,
        ordered_cache_behavior.value.origin_request_policy_id,
        null
      )

      response_headers_policy_id = try(
        aws_cloudfront_response_headers_policy.policy[ordered_cache_behavior.value.response_headers_policy_name].id,
        ordered_cache_behavior.value.response_headers_policy_id,
        null
      )

      dynamic "function_association" {
        for_each = try(ordered_cache_behavior.value.function_associations, [])
        content {
          event_type = function_association.value.event_type
          function_arn = try(
            aws_cloudfront_function.function[function_association.value.function_name].arn,
            function_association.value.function_arn
          )
        }
      }

      # Lambda@Edge support
      dynamic "lambda_function_association" {
        for_each = try(ordered_cache_behavior.value.lambda_function_associations, [])
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = try(lambda_function_association.value.include_body, false)
        }
      }
    }
  }

  # Certificate
  viewer_certificate {
    acm_certificate_arn            = try(each.value.certificate.acm_certificate_arn, null)
    minimum_protocol_version       = try(each.value.certificate.minimum_protocol_version, "TLSv1.2_2021")
    ssl_support_method             = try(each.value.certificate.acm_certificate_arn, null) != null ? "sni-only" : null
    cloudfront_default_certificate = try(each.value.certificate.acm_certificate_arn, null) == null ? true : false
  }

  # Logging configuration
  dynamic "logging_config" {
    for_each = try(each.value.logging.bucket, null) != null ? [1] : []
    content {
      include_cookies = try(each.value.logging.include_cookies, false)
      bucket          = each.value.logging.bucket
      prefix          = try(each.value.logging.prefix, "cloudfront/${each.key}/")
    }
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = try(each.value.custom_error_responses, [])
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.response_page_path, null)
      error_caching_min_ttl = try(custom_error_response.value.error_caching_min_ttl, 10)
    }
  }

  # Geo-restriction
  restrictions {
    geo_restriction {
      restriction_type = try(each.value.geo_restriction.type, "none")
      locations        = try(each.value.geo_restriction.locations, [])
    }
  }

  tags = merge(
    local.default_tags,
    var.common_tags,
    try(each.value.tags, {})
  )
}
