# Lambda@Edge and CloudFront Functions

## ⚠️ Important

**Lambda@Edge**: The module ATTACHES Lambda@Edge functions but does NOT CREATE them. You must create Lambda@Edge functions yourself.

**CloudFront Functions**: The module CREATES and MANAGES CloudFront Functions from your YAML configuration files.

## CloudFront Functions (Managed by Module)

### 1. Define Functions in YAML

Create `functions/cloudfront-functions.yaml`:

```yaml
# CloudFront Functions configuration
url-rewrite:
  comment: "Rewrite URLs for SPA routing"
  runtime: "cloudfront-js-2.0"
  publish: true
  code_file: "src/url-rewrite.js"

add-headers:
  comment: "Add custom security headers"
  runtime: "cloudfront-js-2.0"
  publish: true
  code_file: "src/add-headers.js"
```

### 2. Create Function Code

Create the JavaScript files in `functions/src/`:

**functions/src/url-rewrite.js:**
```javascript
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Rewrite to index.html for SPA routing
    if (!uri.includes('.')) {
        request.uri = '/index.html';
    }

    return request;
}
```

**functions/src/add-headers.js:**
```javascript
function handler(event) {
    var response = event.response;
    var headers = response.headers;

    headers['x-custom-header'] = { value: 'CloudFront-Function' };
    headers['x-frame-options'] = { value: 'DENY' };

    return response;
}
```

### 3. Reference in Distribution YAML

Use `function_name` to reference functions defined in your YAML:

```yaml
# distributions/website.yaml
default_behavior:
  target_origin_id: s3-origin

  # Reference CloudFront Function by name
  function_associations:
    - event_type: viewer-request
      function_name: url-rewrite
    - event_type: viewer-response
      function_name: add-headers

behaviors:
  - path_pattern: "/api/*"
    target_origin_id: api-origin
    function_associations:
      - event_type: viewer-request
        function_name: cache-key-normalize
```

Alternatively, use `function_arn` for external functions:

```yaml
function_associations:
  - event_type: viewer-request
    function_arn: "arn:aws:cloudfront::123456789012:function/external-function"
```

## Lambda@Edge (Attach Only)

### 1. Create the Lambda@Edge Function

```hcl
# main.tf
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"  # Required
}

resource "aws_iam_role" "lambda_edge" {
  provider = aws.us_east_1
  name     = "lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }]
  })
}

resource "aws_lambda_function" "auth" {
  provider = aws.us_east_1  # Required

  filename      = "lambda/auth.zip"
  function_name = "cloudfront-auth"
  handler       = "index.handler"
  runtime       = "python3.11"
  publish       = true  # Required

  role = aws_iam_role.lambda_edge.arn
}

# Retrieve ARN with version
output "auth_lambda_arn" {
  value = aws_lambda_function.auth.qualified_arn
  # Result: arn:aws:lambda:us-east-1:123:function:cloudfront-auth:1
}
```

### 2. Reference in YAML

```yaml
# distributions/website.yaml
default_behavior:
  target_origin_id: s3-origin

  # Lambda@Edge (you create the function)
  lambda_associations:
    - event_type: viewer-request
      lambda_arn: "arn:aws:lambda:us-east-1:123:function:cloudfront-auth:1"
      include_body: false
```

## When to Use What?

### Lambda@Edge
- Complex logic
- External API calls
- Database access
- OAuth/JWT authentication
- A/B testing with external data
- Access to full Node.js/Python runtime
- Longer execution time needed (up to 30 seconds)

### CloudFront Functions
- URL rewriting
- Simple header manipulation
- Redirections
- Cache key normalization
- Simple request/response transformations
- Very fast (< 1ms)
- Much cheaper than Lambda@Edge
- Limited to viewer-request and viewer-response events only

## Event Types

**Lambda@Edge (4 events):**
- `viewer-request` - Before CloudFront cache lookup
- `origin-request` - Before forwarding to origin
- `origin-response` - After receiving from origin
- `viewer-response` - Before returning to viewer

**CloudFront Functions (2 events):**
- `viewer-request` - Before CloudFront cache lookup
- `viewer-response` - Before returning to viewer

## Complete Examples

### Example: SPA with URL Rewriting

**functions/cloudfront-functions.yaml:**
```yaml
spa-rewrite:
  comment: "SPA URL rewriting"
  runtime: "cloudfront-js-2.0"
  code_file: "src/spa-rewrite.js"
```

**distributions/spa.yaml:**
```yaml
default_behavior:
  target_origin_id: s3-website
  function_associations:
    - event_type: viewer-request
      function_name: spa-rewrite
```

### Example: Multi-Function Pipeline

```yaml
default_behavior:
  target_origin_id: s3-origin

  # CloudFront Functions (fast, cheap)
  function_associations:
    - event_type: viewer-request
      function_name: cache-key-normalize
    - event_type: viewer-response
      function_name: add-security-headers

  # Lambda@Edge (complex logic)
  lambda_associations:
    - event_type: origin-request
      lambda_arn: "arn:aws:lambda:us-east-1:123:function:auth:1"
```

## Best Practices

1. **Use CloudFront Functions when possible** - They're faster and cheaper
2. **Keep functions small** - CloudFront Functions have a 10KB limit
3. **Test locally** - Use the CloudFront Function test feature
4. **Version your Lambda@Edge** - Always use qualified ARNs with version
5. **Monitor performance** - Check execution times and errors
6. **Cache function results** - Use headers to cache transformed requests

## Troubleshooting

### CloudFront Function Errors

1. Check function syntax in CloudFront console
2. Use the test feature with sample events
3. Review CloudWatch Logs
4. Verify runtime version (`cloudfront-js-2.0` recommended)

### Lambda@Edge Errors

1. Ensure function is in `us-east-1` region
2. Verify `publish = true` is set
3. Use qualified ARN with version number
4. Check CloudWatch Logs in the region where function executed
5. Verify IAM role has correct permissions

## References

- [CloudFront Functions Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
- [Lambda@Edge Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html)
- [CloudFront Functions vs Lambda@Edge](https://aws.amazon.com/blogs/aws/introducing-cloudfront-functions-run-your-code-at-the-edge-with-low-latency-at-any-scale/)
