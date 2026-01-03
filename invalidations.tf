# CloudFront Cache Invalidations
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html

resource "null_resource" "cache_invalidation" {
  for_each = local.invalidation_paths

  # Trigger invalidation on every apply
  triggers = {
    always_run      = timestamp()
    distribution_id = aws_cloudfront_distribution.dist[each.key].id
    paths           = join(",", each.value)
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws cloudfront create-invalidation \
        --distribution-id ${self.triggers.distribution_id} \
        --paths ${join(" ", each.value)} \
        --query 'Invalidation.Id' \
        --output text
    EOT
  }

  depends_on = [
    aws_cloudfront_distribution.dist
  ]
}
