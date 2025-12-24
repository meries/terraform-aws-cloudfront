# Route53 Records

# Data source to automatically detect Route53 zones based on domain names
# This creates a lookup for each unique zone_name from aliases
# https://registry.terraform.io/providers/hashicorp/awS/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "zones" {
  for_each = toset([
    for item in local.all_aliases :
    item.zone_name
    if try(local.distributions[item.dist_name].create_dns_records, true)
  ])

  name         = each.value
  private_zone = false
}

# Route53 A records (IPv4)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "cloudfront_ipv4" {
  for_each = local.route53_records

  zone_id = each.value.zone_id
  name    = each.value.alias
  type    = "A"

  alias {
    name                   = each.value.domain_name
    zone_id                = each.value.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 AAAA records (IPv6)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "cloudfront_ipv6" {
  for_each = {
    for k, v in local.route53_records : k => v
    if try(local.distributions[v.dist_name].ipv6_enabled, true)
  }

  zone_id = each.value.zone_id
  name    = each.value.alias
  type    = "AAAA"

  alias {
    name                   = each.value.domain_name
    zone_id                = each.value.hosted_zone_id
    evaluate_target_health = false
  }
}
