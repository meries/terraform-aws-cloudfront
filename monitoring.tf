# CloudWatch Monitoring

# CloudFront Additional Metrics Subscription
# Enables real-time metrics and additional CloudWatch metrics
# Configured per distribution in YAML: monitoring.enable_additional_metrics: true
# Note: This incurs additional costs ($0.01 per 1,000 requests)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_monitoring_subscription
resource "aws_cloudfront_monitoring_subscription" "metrics" {
  for_each = {
    for k, v in local.monitoring_config :
    k => v if v.enable_additional_metrics == true
  }

  distribution_id = aws_cloudfront_distribution.dist[each.key].id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}

# CloudWatch alarms for 4xx error rate
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "error_rate_4xx" {
  for_each = local.monitored_distributions

  provider = aws.us_east_1

  alarm_name          = "${var.naming_prefix}${each.key}-4xx-error-rate${var.naming_suffix}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = each.value.error_rate_evaluation_periods
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.error_rate_threshold
  alarm_description   = "High 4xx error rate for distribution ${each.key}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.dist[each.key].id
  }

  alarm_actions = each.value.sns_topic_arn != null ? [each.value.sns_topic_arn] : []

  tags = merge(
    local.default_tags,
    var.common_tags,
    {
      distribution = each.key
    }
  )
}

# CloudWatch alarms for 5xx error rate
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "error_rate_5xx" {
  for_each = local.monitored_distributions

  provider = aws.us_east_1

  alarm_name          = "${var.naming_prefix}${each.key}-5xx-error-rate${var.naming_suffix}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = each.value.error_rate_evaluation_periods
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.error_rate_threshold
  alarm_description   = "High 5xx error rate for distribution ${each.key}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.dist[each.key].id
  }

  alarm_actions = each.value.sns_topic_arn != null ? [each.value.sns_topic_arn] : []

  tags = merge(
    local.default_tags,
    var.common_tags,
    {
      distribution = each.key
    }
  )
}

# Dashboard CloudWatch (optional)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard
resource "aws_cloudwatch_dashboard" "cloudfront" {
  for_each = {
    for dist_name, config in local.monitored_distributions :
    dist_name => config
    if config.create_dashboard
  }

  provider = aws.us_east_1

  dashboard_name = "${var.naming_prefix}${each.key}-cloudfront${var.naming_suffix}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", { stat = "Sum", label = "Requests" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "${each.key} - Requests"
          period  = 300
          dimensions = {
            DistributionId = aws_cloudfront_distribution.dist[each.key].id
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CloudFront", "4xxErrorRate", { stat = "Average", label = "4xx Rate" }],
            [".", "5xxErrorRate", { stat = "Average", label = "5xx Rate" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "${each.key} - Error Rates"
          period  = 300
          dimensions = {
            DistributionId = aws_cloudfront_distribution.dist[each.key].id
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CloudFront", "BytesDownloaded", { stat = "Sum", label = "Downloaded" }],
            [".", "BytesUploaded", { stat = "Sum", label = "Uploaded" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "${each.key} - Data Transfer"
          period  = 300
          dimensions = {
            DistributionId = aws_cloudfront_distribution.dist[each.key].id
          }
        }
      }
    ]
  })
}
