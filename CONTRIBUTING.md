# Contributing

## Reporting Issues

Before opening an issue:
- Check if it already exists
- Include Terraform and AWS provider versions
- Provide sanitized configuration files
- Include error messages and steps to reproduce

## Making Changes

### Setup

```bash
git clone https://github.com/meries/terraform-aws-cloudfront.git
cd terraform-aws-cloudfront
```

### Prerequisites

- Terraform >= 1.5.7
- AWS CLI configured
- terraform-docs (for docs generation)
- tflint (for linting)

### Development

```bash
# Format and validate
terraform fmt -recursive
terraform validate
tflint

# Test locally
cd examples/simple
terraform init
terraform plan
terraform apply
terraform destroy
```

### Pull Requests

1. Fork and create a feature branch
2. Make your changes
3. Test thoroughly (see testing checklist below)
4. Update CHANGELOG.md
5. Update documentation if needed
6. Open a PR with a clear description

**Testing checklist:**
- [ ] `terraform init/plan/apply/destroy` work
- [ ] Resources created correctly in AWS
- [ ] Distribution serves content
- [ ] Behaviors sorted properly
- [ ] OAC attached to S3 origins
- [ ] No merge conflicts with main

## Code Style

Follow standard Terraform conventions:

```hcl
# Use try() for optional values
enabled = try(each.value.enabled, true)

# Align equals signs
resource "aws_cloudfront_distribution" "dist" {
  for_each        = local.distributions
  enabled         = try(each.value.enabled, true)
  is_ipv6_enabled = try(each.value.ipv6_enabled, true)
  comment         = try(each.value.comment, each.key)
}

# Add comments for complex logic
# Sort behaviors based on path patterns (See BEHAVIORS.md)
# Format: <specificity>__<wildcard>__<length>__<path>
sortable_behaviors = {
  for behavior in local.all_behaviors :
  format("%s__%s__%03d__%s", ...) => behavior
}
```

## Commit Messages

Use conventional commits:

```
feat(scope): add new feature
fix(scope): correct bug
docs: update documentation
refactor: improve code structure
```

Examples:
```
feat(behaviors): add automatic behavior sorting

Implement sorting based on path pattern specificity
to ensure correct CloudFront evaluation order.

Fixes #42
```

## Release Process (Maintainers)

1. Update CHANGELOG.md
2. Update version in variables.tf
3. Tag release: `git tag -a v1.2.0 -m "Release v1.2.0"`
4. Push: `git push origin v1.2.0`
5. Create GitHub release

## License

Contributions are licensed under MIT.
