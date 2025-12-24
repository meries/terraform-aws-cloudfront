# CloudFront Cache Behaviors Sorting

## Overview

This module implements an automatic sorting system for CloudFront cache behaviors. Behaviors are sorted according to multiple criteria to ensure CloudFront evaluates them in the correct order.

CloudFront uses the **first matching behavior** for the request path. Therefore, it is crucial that behaviors are ordered from most specific to most generic. Automatic sorting prevents one path from inadvertently overriding another by ensuring proper evaluation order.

## Sorting Modes

The module supports two sorting modes configured per distribution in the YAML file:

### `auto` (default)
The module automatically sorts behaviors from most specific to least specific based on multiple criteria (see below). This is the recommended mode to prevent path conflicts.

```yaml
# distributions/my-app.yaml
enabled: true
comment: "My application"

# Behavior sorting mode: 'auto' (automatic sorting) or 'manual' (keep YAML order)
# Default: auto
behavior_sorting: auto

origins:
  - id: s3-origin
    domain_name: bucket.s3.eu-west-1.amazonaws.com
    type: s3
# ...
```

### `manual`
Behaviors are kept in the exact order they are defined in your YAML files. Use this mode only if you need full control over the order and understand CloudFront's behavior matching rules.

```yaml
# distributions/my-app.yaml
enabled: true
comment: "My application"

# Manual mode: you control the exact order of behaviors
behavior_sorting: manual

origins:
  - id: s3-origin
    domain_name: bucket.s3.eu-west-1.amazonaws.com
    type: s3
# ...
```

**⚠️ Warning**: In `manual` mode, you are responsible for ensuring behaviors are ordered correctly. A generic pattern like `/*` placed before specific patterns will prevent those specific patterns from ever being matched.

**💡 Multi-Brand Flexibility**: Each distribution can have its own sorting mode. For example, in a multi-brand setup, Brand A can use `auto` while Brand B uses `manual`.

## Sorting Criteria (Auto Mode)

When using `behavior_sorting: auto` in your distribution YAML, the module automatically sorts behaviors according to these criteria, in priority order:

### 1. Path Pattern Specificity

Paths are classified by specificity type:
- **Exact paths without wildcards** (highest priority)
- **Paths with wildcards** (lowest priority)

### 2. Prefix Grouping

For paths without wildcards, alphabetical grouping is performed on the first path segment.
For example, all `/api/*` paths are grouped together.

### 3. Path Length

Longer paths (more specific) take priority over shorter paths.
For example: `/api/v1/users` is processed before `/api/v1/*`

### 4. Alphabetical Order

In case of equality, a final alphabetical sort is applied on the complete path pattern.

## Sorting Order Examples

### Example 1: API Paths

| Path Pattern | Position | Reason |
|--------------|----------|--------|
| `/api/v1/users/profile` | 1 | Exact path, longest and most specific |
| `/api/v1/users` | 2 | Exact path, shorter |
| `/api/v1/auth` | 3 | Exact path, alphabetical sort |
| `/api/v1/*` | 4 | Wildcard but quite specific |
| `/api/*` | 5 | More generic wildcard |
| `/*` | 6 | Most generic wildcard (catch-all) |

### Example 2: Static Paths

| Path Pattern | Position | Reason |
|--------------|----------|--------|
| `/images/logo.png` | 1 | Exact path to a specific file |
| `/images/icons/*` | 2 | Wildcard in a subfolder |
| `/images/*` | 3 | More generic wildcard |
| `*.jpg` | 4 | Wildcard by extension |
| `*.png` | 5 | Wildcard by extension (alphabetical order) |
| `*` | 6 | Catch-all wildcard |

### Example 3: Mixed Case

| Path Pattern | Position | Reason |
|--------------|----------|--------|
| `/` | 1 | Root path (special case) |
| `/.well-known/acme-challenge/*` | 2 | Starts with "." (hidden files) |
| `/admin/dashboard` | 3 | Exact path in /admin |
| `/api/health` | 4 | Exact path in /api |
| `/static/css/main.css` | 5 | Exact path in /static |
| `/admin/*` | 6 | Wildcard /admin |
| `/api/*` | 7 | Wildcard /api |
| `/static/*` | 8 | Wildcard /static |
| `*.json` | 9 | Wildcard by extension |
| `*` | 10 | Final catch-all |

## Configuration in YAML Files

To define behaviors in your CloudFront distributions, add a `behaviors` section in your distribution YAML file:

```yaml
# distributions/my-app.yaml
enabled: true
comment: "Web application with API"

# Behavior sorting mode: 'auto' (automatic sorting) or 'manual' (keep YAML order)
# Default: auto
behavior_sorting: auto

origins:
  - id: s3-static
    domain_name: my-bucket.s3.eu-west-1.amazonaws.com
    type: s3

  - id: api-backend
    domain_name: api.example.com
    type: custom

default_behavior:
  target_origin_id: s3-static
  cache_policy_name: "default-cache"

# Behaviors - order doesn't matter in 'auto' mode, they will be sorted automatically
behaviors:
  - path_pattern: "/api/*"
    target_origin_id: api-backend
    cache_policy_name: "no-cache"
    viewer_protocol_policy: https-only
    allowed_methods: ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods: ["GET", "HEAD"]
    compress: false

  - path_pattern: "*.jpg"
    target_origin_id: s3-static
    cache_policy_name: "images-cache"
    viewer_protocol_policy: redirect-to-https
    compress: true

  - path_pattern: "*.png"
    target_origin_id: s3-static
    cache_policy_name: "images-cache"
    compress: true

  - path_pattern: "/api/health"
    target_origin_id: api-backend
    cache_policy_name: "health-check-cache"
    viewer_protocol_policy: https-only
    allowed_methods: ["GET", "HEAD"]
```

Automatic sorting result (CloudFront evaluation order):
1. `/api/health` (exact path, more specific than wildcard)
2. `/api/*` (wildcard in /api)
3. `*.jpg` (wildcard by extension, alphabetical order)
4. `*.png` (wildcard by extension, alphabetical order)

## Supported Behavior Properties

Each behavior can contain the following properties:

### Required Properties
- `path_pattern`: The path pattern (e.g., `/api/*`, `*.jpg`)
- `target_origin_id`: The target origin ID (must match an origin defined in `origins`)

### Optional Properties

#### Cache and Compression
- `cache_policy_name`: Name of a cache policy defined in `policies/cache-policies.yaml`
- `cache_policy_id`: ID of an AWS managed cache policy (alternative to `cache_policy_name`)
- `compress`: Enable gzip/brotli compression (default: `true`)

#### Protocol and Methods
- `viewer_protocol_policy`: Protocol policy (default: `redirect-to-https`)
  - `allow-all`: HTTP and HTTPS
  - `redirect-to-https`: HTTP → HTTPS redirect
  - `https-only`: HTTPS only
- `allowed_methods`: Allowed HTTP methods (default: `["GET", "HEAD", "OPTIONS"]`)
- `cached_methods`: Cached methods (default: `["GET", "HEAD"]`)

#### Additional Policies
- `origin_request_policy_id`: ID of an origin request policy
- `response_headers_policy_id`: ID of a response headers policy

#### CloudFront Functions
- `function_associations`: List of CloudFront function associations
  ```yaml
  function_associations:
    - event_type: viewer-request
      function_arn: arn:aws:cloudfront::123456789012:function/my-function
  ```

## Technical Details

### Implementation

Sorting is performed at the Terraform locals level through three steps:

1. **Flatten**: All behaviors from all distributions are flattened into `local.all_behaviors`

2. **Sort key generation**: Each behavior receives a composite key in the format:
   ```
   <dist_name>__<specificity>__<wildcard>__<length>__<path>
   ```

   Where:
   - `dist_name`: Distribution name (to group by distribution)
   - `specificity`: Specificity indicator (`000000` for `/`, `000001` for `.file`, segment for paths, `zzzzzz` for wildcards)
   - `wildcard`: `0` if no wildcard, `1` if wildcard present
   - `length`: `999 - length(path)` to invert order (longer = higher priority)
   - `path`: Complete path pattern for final alphabetical sort

3. **Sort and group**: Keys are sorted lexicographically, then behaviors are grouped by distribution in `local.sorted_behaviors_by_dist`

### Source Code

The sorting locals are located in [main.tf:39-87](main.tf#L39-L87).

The `ordered_cache_behavior` block uses these locals in [main.tf:154-189](main.tf#L154-L189).

## Best Practices

1. Don't worry about order in your YAML files, sorting is automatic
2. Use specific paths before wildcards when possible
3. Test your behaviors with `terraform plan` to verify the generated order
4. Document complex behaviors with YAML comments
5. Prefer reusable cache policies over multiple behaviors

## Troubleshooting

### Issue: Behavior Not Applied

If a behavior doesn't seem to be applied:
1. Check the generated order with `terraform plan`
2. A more generic behavior might be evaluated first
3. Use a more specific path or verify the pattern syntax

### Issue: Unexpected Order

If the behavior order is not as expected:
1. Consult the sorting criteria above
2. Verify that paths are properly formatted (e.g., `/api/*` vs `api/*`)
3. Use `terraform plan` to see the final order

### Issue: Terraform Error

If Terraform returns an error on behaviors:
1. Verify that `target_origin_id` matches an existing origin
2. Verify that `cache_policy_name` exists in your policies
3. Ensure that `path_pattern` is valid for CloudFront

## References

- [CloudFront Cache Behaviors Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesCacheBehavior)
- [Path Pattern Matching in CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesPathPattern)
