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

  # Development paths
  distributions_path = "${path.module}/distributions"
  policies_path      = "${path.module}/policies"
  functions_path     = "${path.module}/functions"

  # Development naming
  naming_prefix = "dev"
  naming_suffix = ""

  # Development settings (minimal features for cost optimization)
  create_route53_records = false # Manual DNS in dev
  create_log_buckets     = false # No logs in dev
  enable_monitoring      = false # No monitoring in dev

  # Development tags
  common_tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
    Team        = "Platform"
    Project     = "CloudFront-Example"
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
