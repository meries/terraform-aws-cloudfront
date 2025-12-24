# TODO - CloudFront Terraform Module

## High Priority

### Security
- [x] WAF Integration (web_acl_id parameter)
- [x] Response Headers Policies
- [x] Origin Request Policies
- [ ] Trusted Key Groups for signed URLs

### Distribution Features
- [ ] Origin Groups (automatic failover)
- [x] Origin Shield
- [ ] Continuous Deployment (blue/green)
- [ ] Custom Error Pages (enhancement)

### Monitoring
- [ ] Enhanced CloudWatch metrics (cache hit/miss, latency)
- [ ] Real-time Logs (Kinesis streams)
- [ ] Improved dashboards

## Medium Priority

### Infrastructure
- [ ] Origin Access Identity (legacy support)
- [ ] Cache Invalidation automation
- [ ] Field-Level Encryption

### Testing & Validation
- [x] Terraform tests (`terraform test`)
- [x] YAML schema validation
- [ ] Full LocalStack support
- [ ] Pre-commit hooks (fmt, validate, tfsec)

### Developer Experience
- [ ] JSON Schema for YAML (IDE autocomplete)
- [ ] Enhanced outputs (log buckets, etc.)
- [ ] More examples (WAF, Lambda@Edge, SPA, e-commerce)
- [ ] Variables validation

### Documentation
- [ ] Architecture diagrams
- [ ] Migration guides (CloudFormation, Terraform legacy)
- [ ] Cost optimization guide
- [ ] Troubleshooting guide

## Low Priority

### CI/CD
- [x] GitHub Actions workflows
- [ ] GitLab CI templates
- [ ] Terraform Cloud examples

### Multi-Account
- [ ] Cross-account IAM automation
- [ ] AWS Organizations integration

### Nice to Have
- [ ] Import script (existing distributions to YAML)
- [ ] CLI tool (validation, generation)
- [ ] VS Code extension
- [ ] CloudFront KeyValueStore support

## Quick Wins

- [ ] Tags management (mandatory tags, cost allocation)
- [ ] Naming validation
- [ ] Default values documentation
- [ ] README (TOC, badges, FAQ)
- [ ] Configurable lifecycle rules (log buckets)

## Bugs & Improvements

- [ ] Clearer error messages
- [ ] Input validation before apply
- [ ] Performance (reduce data sources)
- [ ] State management
