# CloudFront Key Value Stores
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_value_store
resource "aws_cloudfront_key_value_store" "kvs" {
  for_each = local.key_value_stores

  name    = "${var.naming_prefix}${each.key}${var.naming_suffix}"
  comment = try(each.value.comment, "Key Value Store ${each.key}")
}

# Individual key-value pairs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfrontkeyvaluestore_key
resource "aws_cloudfrontkeyvaluestore_key" "items" {
  for_each = merge([
    for kvs_name, kvs_config in local.key_value_stores : {
      for item in try(kvs_config.items, []) :
      "${kvs_name}__${item.key}" => {
        kvs_name = kvs_name
        key      = item.key
        value    = item.value
      }
    }
  ]...)

  key_value_store_arn = aws_cloudfront_key_value_store.kvs[each.value.kvs_name].arn
  key                 = each.value.key
  value               = each.value.value
}
