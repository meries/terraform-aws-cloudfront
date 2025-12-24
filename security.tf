# Origin Access Control for S3
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
resource "aws_cloudfront_origin_access_control" "oac" {
  for_each = {
    for origin in local.all_origins :
    "${origin.dist_name}-${origin.origin_id}" => origin
    if origin.origin_type == "s3"
  }

  name                              = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  description                       = "OAC for ${each.key}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
