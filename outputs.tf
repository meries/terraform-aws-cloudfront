output "distribution_ids" {
  description = "Map of distribution IDs"
  value = {
    for k, v in aws_cloudfront_distribution.dist :
    k => v.id
  }
}

output "distribution_arns" {
  description = "Map of distribution ARNs"
  value = {
    for k, v in aws_cloudfront_distribution.dist :
    k => v.arn
  }
}

output "distribution_domain_names" {
  description = "Map of CloudFront domain names"
  value = {
    for k, v in aws_cloudfront_distribution.dist :
    k => v.domain_name
  }
}

output "distribution_hosted_zone_ids" {
  description = "Map of CloudFront hosted zone IDs"
  value = {
    for k, v in aws_cloudfront_distribution.dist :
    k => v.hosted_zone_id
  }
}

output "cache_policy_ids" {
  description = "Map of cache policy IDs"
  value = {
    for k, v in aws_cloudfront_cache_policy.policy :
    k => v.id
  }
}

output "oac_ids" {
  description = "Map of Origin Access Control IDs"
  value = {
    for k, v in aws_cloudfront_origin_access_control.oac :
    k => v.id
  }
}

output "cloudfront_function_arns" {
  description = "Map of CloudFront Function ARNs"
  value = {
    for k, v in aws_cloudfront_function.function :
    k => v.arn
  }
}

output "cloudfront_function_etags" {
  description = "Map of CloudFront Function ETags"
  value = {
    for k, v in aws_cloudfront_function.function :
    k => v.etag
  }
}

output "key_value_store_ids" {
  description = "Map of Key Value Store names to IDs"
  value = {
    for k, v in aws_cloudfront_key_value_store.kvs : k => v.id
  }
}

output "key_value_store_arns" {
  description = "Map of Key Value Store names to ARNs"
  value = {
    for k, v in aws_cloudfront_key_value_store.kvs : k => v.arn
  }
}

output "trusted_key_group_ids" {
  description = "Map of Trusted Key Group names to IDs"
  value = {
    for k, v in aws_cloudfront_key_group.group : k => v.id
  }
}

output "public_key_ids" {
  description = "Map of Public Key names to IDs (composite key: keygroup__keyname)"
  value = {
    for k, v in aws_cloudfront_public_key.key : k => v.id
  }
}
