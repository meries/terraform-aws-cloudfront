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
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront" {
  source  = "meries/cloudfront/aws"
  version = "1.0.4"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Default: Path to your YAML configurations (can be overridden if needed)
  # distributions_path    = "${path.module}/distributions"
  # policies_path         = "${path.module}/policies"
  # functions_path        = "${path.module}/functions"
  # key_value_stores_path = "${path.module}/key-value-stores"

  # Optional: Resource naming
  naming_prefix = "ha-"

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Example     = "origin-groups-failover"
  }
}

# Outputs
output "distribution_ids" {
  description = "CloudFront distribution IDs"
  value       = module.cloudfront.distribution_ids
}

output "distribution_domain_names" {
  description = "CloudFront domain names"
  value       = module.cloudfront.distribution_domain_names
}
