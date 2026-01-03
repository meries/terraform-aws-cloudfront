variable "distributions_path" {
  description = "Path to the directory containing CloudFront distribution YAML configuration files. Each YAML file defines a distribution with origins, behaviors, and cache policies"
  type        = string
  default     = "./distributions"
}

variable "policies_path" {
  description = "Path to the directory containing CloudFront policy YAML files (cache policies, origin request policies, response headers policies)"
  type        = string
  default     = "./policies"
}

variable "functions_path" {
  description = "Path to the directory containing CloudFront Functions JavaScript files. Each .js file represents a function that runs at edge locations"
  type        = string
  default     = "./functions"
}

variable "key_value_stores_path" {
  description = "Path to the directory containing CloudFront KeyValueStore YAML files for low-latency data storage accessible from CloudFront Functions"
  type        = string
  default     = "./key-value-stores"
}

variable "trusted_key_groups_path" {
  description = "Path to the directory containing Trusted Key Groups YAML files for signed URLs and signed cookies (private content access control)"
  type        = string
  default     = "./trusted-key-groups"
}

variable "create_log_buckets" {
  description = "Automatically create and configure S3 buckets for CloudFront access logs with appropriate policies, lifecycle rules, and encryption"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring with alarms for error rates (4xx, 5xx) and optional dashboards for CloudFront distribution metrics"
  type        = bool
  default     = false
}

variable "monitoring_config" {
  description = "CloudWatch monitoring configuration with error_rate_threshold (%), error_rate_evaluation_periods, sns_topic_arn for notifications, and create_dashboard flag"
  type = object({
    error_rate_threshold          = optional(number, 5)
    error_rate_evaluation_periods = optional(number, 2)
    sns_topic_arn                 = optional(string)
    create_dashboard              = optional(bool, false)
  })
  default = {}
}

variable "naming_prefix" {
  description = "Prefix string to prepend to all resource names. Useful for environment segregation (e.g., 'prod-', 'staging-') or multi-tenant deployments"
  type        = string
  default     = ""
}

variable "naming_suffix" {
  description = "Suffix string to append to all resource names. Useful for regional identification (e.g., '-us-east-1') or versioning (e.g., '-v2')"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Map of tags to apply to all resources created by this module. Example: { Environment = 'production', ManagedBy = 'terraform' }"
  type        = map(string)
  default     = {}
}

variable "enable_default_tags" {
  description = "Enable automatic addition of default tags (ManagedBy='terraform', ModuleVersion) to all resources, merged with common_tags"
  type        = bool
  default     = true
}

variable "module_version" {
  description = "Version identifier for this module instance, added as a tag to all resources when enable_default_tags is true. Example: '1.0.0'"
  type        = string
  default     = ""
}
