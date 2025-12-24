# AWS Managed Policies - IDs

List of the most common AWS Managed policies IDs.

## Cache Policies

```yaml
# In your YAML, use the ID directly
default_behavior:
  cache_policy_id: "658327ea-f89d-4fab-a63d-7e88639e58f6"
```

### Available Policies

**CachingOptimized** (`658327ea-f89d-4fab-a63d-7e88639e58f6`)
- TTL: 1 day (default), 1 year (max)
- Compression: Gzip + Brotli
- Usage: Static sites, assets

**CachingDisabled** (`4135ea2d-6df8-44a3-9df3-4b5a84be39ad`)
- TTL: 0
- Usage: Dynamic APIs, no caching

**CachingOptimizedForUncompressedObjects** (`b2884449-e4de-46a7-ac36-70bc7f1ddd6d`)
- No compression
- Usage: Images, videos already compressed

**Elemental-MediaPackage** (`08627262-05a9-4f76-9ded-b50ca2e3a84f`)
- Usage: Video streaming

## Origin Request Policies

**AllViewer** (`216adef6-5c7f-47e4-b989-5492eafa07d3`)
- Forward all headers, cookies, query strings
- Usage: Origin receives everything

**AllViewerExceptHostHeader** (`b689b0a8-53d0-40ab-baf2-68738e2966ac`)
- Like AllViewer but without Host header

**CORS-S3Origin** (`88a5eaf4-2fd4-4709-b370-b4c650ea3fcf`)
- CORS headers for S3
- Usage: S3 buckets with CORS

**CORS-CustomOrigin** (`59781a5b-3903-41f3-afcb-af62929ccde1`)
- CORS headers for custom origins
- Usage: ALB, API Gateway

**UserAgentRefererHeaders** (`acba4595-bd28-49b8-b9fe-13317c0390fa`)
- User-Agent + Referer
- Usage: Analytics, logs

## Response Headers Policies

**SecurityHeadersPolicy** (`67f7725c-6f97-4210-82d7-5512b31e9d03`)
- HSTS, CSP, X-Frame-Options, etc.
- Usage: Standard security

**SimpleCORS** (`60669652-455b-4ae9-85a4-c4c02393f86c`)
- Access-Control-Allow-Origin: *
- Usage: Public APIs

**CORS-with-preflight-and-SecurityHeadersPolicy** (`e61eb60c-9c35-4d20-a928-2b84e02af89c`)
- CORS + Security headers
- Usage: APIs with security

## Usage Example

```yaml
# distributions/api.yaml
default_behavior:
  # AWS Managed policies by ID
  cache_policy_id: "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # CachingDisabled
  origin_request_policy_id: "59781a5b-3903-41f3-afcb-af62929ccde1"  # CORS-CustomOrigin
  response_headers_policy_id: "60669652-455b-4ae9-85a4-c4c02393f86c"  # SimpleCORS
```

Or mix with your custom policies:

```yaml
default_behavior:
  cache_policy_name: "my-custom-policy"  # Defined in policies/
  origin_request_policy_id: "216adef6-5c7f-47e4-b989-5492eafa07d3"  # AWS Managed
```

## Reference

See AWS documentation for the complete list:
https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
