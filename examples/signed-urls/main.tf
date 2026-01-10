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
  source  = "meries/cloudfront/aws"
  version = "1.0.4"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Project     = "Signed-URLs-Example"
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

output "trusted_key_group_ids" {
  description = "Trusted Key Group IDs for signing URLs/cookies"
  value       = module.cloudfront.trusted_key_group_ids
}
