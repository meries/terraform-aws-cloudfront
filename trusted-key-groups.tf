# CloudFront Trusted Key Groups (Signed URLs & Cookies)
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html

# Public Keys
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_public_key
resource "aws_cloudfront_public_key" "key" {
  for_each = local.public_keys

  name    = "${var.naming_prefix}${each.value.name}${var.naming_suffix}"
  comment = try(each.value.comment, "Public key ${each.value.name}")
  encoded_key = try(
    file("${var.trusted_key_groups_path}/${each.value.encoded_key_file}"),
    each.value.encoded_key
  )
}

# Key Groups
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_group
resource "aws_cloudfront_key_group" "group" {
  for_each = local.trusted_key_groups

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  comment = try(each.value.comment, "Key group ${each.key}")

  items = [
    for key in try(each.value.public_keys, []) :
    aws_cloudfront_public_key.key["${each.key}__${key.name}"].id
  ]
}
