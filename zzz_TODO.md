# TODO - CloudFront Terraform Module

## 🔥 Top Priorities

### Core Features
- [ ] Continuous Deployment (blue/green deployments)
- [ ] Lambda@Edge module integration (separate module)
- [ ] Support an Amazon CloudFront VPC origin (endpoint)

### Monitoring & Observability
- [ ] Enhanced CloudWatch metrics (cache hit/miss ratios, latency p50/p95/p99)
- [ ] Real-time Logs to Kinesis Data Streams
- [ ] Improved CloudWatch dashboards with key metrics

### Security
- [x] Prevent Destroy Protection

### Documentation
- [ ] Architecture diagrams (mermaid or draw.io)
- [ ] Cost optimization guide
- [ ] Troubleshooting guide with common issues

## 📋 Secondary Priorities

### Infrastructure Automation
- [ ] Cache invalidation automation (on deployment)
- [ ] Import script (convert existing distributions to YAML)

### Testing
- [ ] Full LocalStack integration for local testing

## 💡 Nice to Have
- [ ] CLI tool for YAML validation and generation
- [ ] Migration guides (from CloudFormation or other Terraform modules)
- [ ] Cross-account IAM automation for multi-account setups
