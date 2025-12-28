terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront" {
  source = "../../.."

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Default: Path to your YAML configurations (can be overridden if needed)
  # distributions_path    = "${path.module}/distributions"
  # policies_path         = "${path.module}/policies"
  # functions_path        = "${path.module}/functions"
  # key_value_stores_path = "${path.module}/key-value-stores"

  # Production naming
  naming_prefix = "prod"
  naming_suffix = ""

  # Production settings (full feature set)
  create_route53_records = true
  create_log_buckets     = true
  enable_monitoring      = true

  # Production tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Team        = "Platform"
    Project     = "CloudFront-Example"
    CostCenter  = "Engineering"
  }

  # Production monitoring with alerts
  monitoring_config = {
    error_rate_threshold          = 5
    error_rate_evaluation_periods = 2
    sns_topic_arn                 = "arn:aws:sns:eu-west-1:123456789012:cloudfront-alerts-prod"
    create_dashboard              = true
  }

  # Route53 zone mapping
  route53_zones = {
    "www.example.com" = "example.com"
    "example.com"     = "example.com"
  }
}

output "distribution_ids" {
  description = "CloudFront distribution IDs"
  value       = module.cloudfront.distribution_ids
}

output "distribution_domain_names" {
  description = "CloudFront distribution domain names"
  value       = module.cloudfront.distribution_domain_names
}

output "distribution_arns" {
  description = "CloudFront distribution ARNs"
  value       = module.cloudfront.distribution_arns
}

output "cache_policy_ids" {
  description = "Custom cache policy IDs"
  value       = module.cloudfront.cache_policy_ids
}

output "oac_ids" {
  description = "Origin Access Control IDs"
  value       = module.cloudfront.oac_ids
}
