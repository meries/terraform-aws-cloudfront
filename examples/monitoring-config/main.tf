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

  # Monitoring defaults applied to all distributions
  # Can be overridden per distribution in YAML
  monitoring_defaults = {
    enabled                       = false
    error_rate_threshold          = 5
    error_rate_evaluation_periods = 2
    sns_topic_arn                 = null
    create_dashboard              = false
  }

  # Optional: Resource naming
  naming_prefix = "prod-"
  naming_suffix = ""

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
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

output "cloudwatch_alarms_4xx" {
  description = "CloudWatch 4xx error rate alarm ARNs"
  value = {
    for k, v in module.cloudfront.distribution_ids :
    k => "arn:aws:cloudwatch:us-east-1:${data.aws_caller_identity.current.account_id}:alarm:prod-${k}-4xx-error-rate"
  }
}

output "cloudwatch_alarms_5xx" {
  description = "CloudWatch 5xx error rate alarm ARNs"
  value = {
    for k, v in module.cloudfront.distribution_ids :
    k => "arn:aws:cloudwatch:us-east-1:${data.aws_caller_identity.current.account_id}:alarm:prod-${k}-5xx-error-rate"
  }
}

data "aws_caller_identity" "current" {}
