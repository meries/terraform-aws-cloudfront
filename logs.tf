# S3 Log Buckets

# Create S3 buckets for CloudFront logs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = each.key

  tags = merge(
    local.default_tags,
    var.common_tags,
    {
      Name    = each.key
      Purpose = "CloudFront Access Logs"
    }
  )
}

# Enable versioning for log buckets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for log buckets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for log buckets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Set ownership controls for log buckets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket_public_access_block.cloudfront_logs]
}

# Bucket policy to allow CloudFront to write logs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontLogs"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudfront_logs[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = [
              for dist_name, dist in aws_cloudfront_distribution.dist :
              dist.arn
              if try(local.distributions[dist_name].logging.bucket, null) != null &&
              replace(local.distributions[dist_name].logging.bucket, ".s3.amazonaws.com", "") == each.key
            ]
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.cloudfront_logs,
    aws_s3_bucket_ownership_controls.cloudfront_logs,
    aws_cloudfront_distribution.dist
  ]
}

# Optional lifecycle policy to manage log retention
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  for_each = local.log_buckets

  bucket = aws_s3_bucket.cloudfront_logs[each.key].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  depends_on = [aws_s3_bucket_versioning.cloudfront_logs]
}
