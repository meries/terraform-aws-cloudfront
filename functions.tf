# CloudFront Functions
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function
resource "aws_cloudfront_function" "function" {
  for_each = local.cloudfront_functions

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  runtime = try(each.value.runtime, "cloudfront-js-2.0")
  comment = try(each.value.comment, "CloudFront function ${each.key}")
  publish = try(each.value.publish, true)
  code    = file("${var.functions_path}/${try(each.value.code_file, "src/${each.key}.js")}")

  # Key Value Store associations (list of ARNs)
  key_value_store_associations = try(each.value.key_value_store_name, null) != null ? [aws_cloudfront_key_value_store.kvs[each.value.key_value_store_name].arn] : []

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}
