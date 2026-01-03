# Signed URLs Example - Private Content Access Control

This example demonstrates how to restrict access to premium content using CloudFront signed URLs and signed cookies with Trusted Key Groups.

## Architecture

```
User Request
  └─ Backend Application
      ├─ Authenticate user
      ├─ Verify access rights
      └─ Generate signed URL (using private key)
           ↓
      CloudFront
        ├─ Verify signature (using public key)
        ├─ Valid → Serve content
        └─ Invalid → 403 Forbidden
```

## What This Example Does

- Creates CloudFront distribution with signed URL protection on `/premium/*` path
- Manages public keys and key groups via YAML configuration
- Demonstrates two key groups: `video-streaming` and `api-access`
- Shows both inline public keys and file-based public keys

## Use Cases

- **Premium/Paid Content**: Videos, courses, downloads for paying users only
- **Time-Limited Access**: Share files that expire after X hours
- **User-Specific Content**: Content accessible only to authenticated users
- **Private APIs**: Restrict API access to authorized applications

## Prerequisites

1. AWS credentials configured
2. RSA key pair generated (see [Generating Keys](#generating-rsa-key-pair) below)
3. S3 buckets for origins (create before deploying)
4. ACM certificate in `us-east-1` (if using custom domains)

## Generating RSA Key Pair

**IMPORTANT:** Generate these keys before deployment. Keep the private key SECRET!

```bash
# Generate private key (KEEP THIS SECRET!)
openssl genrsa -out private-key.pem 2048

# Generate public key from private key
openssl rsa -pubout -in private-key.pem -out public-key.pem

# Display public key content
cat public-key.pem
```

**Security:**
- Store `private-key.pem` securely (AWS Secrets Manager, Vault, etc.)
- NEVER commit private keys to Git
- Only the public key goes in the YAML configuration

## Configuration Files

### main.tf

```hcl
terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront" {
  source  = "meries/cloudfront/aws"
  version = "1.0.3"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  # Default: Path to your YAML configurations (can be overridden if needed)
  # distributions_path      = "${path.module}/distributions"
  # policies_path           = "${path.module}/policies"
  # functions_path          = "${path.module}/functions"
  # key_value_stores_path   = "${path.module}/key-value-stores"
  # trusted_key_groups_path = "${path.module}/trusted-key-groups"

  # Optional: Tags
  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Project     = "Signed-URLs-Example"
  }
}

# Outputs
output "distribution_ids" {
  description = "CloudFront distribution IDs"
  value       = module.cloudfront.distribution_ids
}

output "distribution_domain_names" {
  description = "CloudFront domain names"
  value       = module.cloudfront.distribution_domain_names
}

output "trusted_key_group_ids" {
  description = "Trusted Key Group IDs"
  value       = module.cloudfront.trusted_key_group_ids
}

output "public_key_ids" {
  description = "Public Key IDs (use as Key-Pair-Id in signed URLs)"
  value       = module.cloudfront.public_key_ids
}
```

### distributions/premium-content.yaml

```yaml
enabled: true
comment: Premium content distribution with signed URLs
price_class: PriceClass_100

# Update with your domain and certificate ARN
aliases:
  - www.example.com

certificate:
  acm_certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  minimum_protocol_version: TLSv1.2_2021

origins:
  - id: s3-premium
    domain_name: my-premium-bucket.s3.eu-west-1.amazonaws.com
    type: s3

  - id: s3-public
    domain_name: my-public-bucket.s3.eu-west-1.amazonaws.com
    type: s3

# Public content (no signing required)
default_behavior:
  target_origin_id: s3-public
  viewer_protocol_policy: redirect-to-https
  cache_policy_name: public-content

behaviors:
  # Premium content - requires signed URLs
  - path_pattern: "/premium/*"
    target_origin_id: s3-premium
    viewer_protocol_policy: redirect-to-https
    cache_policy_name: premium-content
    trusted_key_group_name: video-streaming

  # API access - different key group
  - path_pattern: "/api/*"
    target_origin_id: s3-premium
    viewer_protocol_policy: https-only
    cache_policy_name: api-cache
    trusted_key_group_name: api-access
```

### trusted-key-groups/trusted-key-groups.yaml

```yaml
video-streaming:
  comment: "Keys for premium video content signing"
  public_keys:
    # File-based public key
    - name: "production-key-2024"
      comment: "Production signing key for 2024"
      encoded_key_file: "keys/production-public-key.pem"

    # Inline public key (for rotation)
    - name: "production-key-2025"
      comment: "Rotation key for 2025"
      encoded_key: |
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
        -----END PUBLIC KEY-----

api-access:
  comment: "Keys for API authentication"
  public_keys:
    - name: "api-key-2024"
      comment: "API access key"
      encoded_key: |
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
        -----END PUBLIC KEY-----
```

### policies/cache-policies.yaml

```yaml
public-content:
  comment: "Caching for public content"
  min_ttl: 0
  default_ttl: 86400
  max_ttl: 31536000
  enable_accept_encoding_gzip: true
  enable_accept_encoding_brotli: true
  cookies_behavior: none
  headers_behavior: none
  query_strings_behavior: none

premium-content:
  comment: "Caching for premium signed content"
  min_ttl: 0
  default_ttl: 3600
  max_ttl: 86400
  enable_accept_encoding_gzip: true
  enable_accept_encoding_brotli: true
  cookies_behavior: none
  headers_behavior: none
  query_strings_behavior: none

api-cache:
  comment: "Minimal caching for API"
  min_ttl: 0
  default_ttl: 60
  max_ttl: 3600
  enable_accept_encoding_gzip: true
  cookies_behavior: none
  headers_behavior: none
  query_strings_behavior: all
```

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Get outputs
terraform output distribution_domain_names
terraform output public_key_ids  # You'll need this for signing URLs
```

## Generating Signed URLs

### Backend Implementation (Node.js example)

```javascript
const AWS = require('aws-sdk');

const cloudfront = new AWS.CloudFront.Signer(
  process.env.KEY_PAIR_ID,       // From terraform output: public_key_ids
  process.env.CLOUDFRONT_PRIVATE_KEY  // Your private key content
);

// Generate signed URL
app.get('/api/get-premium-video', async (req, res) => {
  // 1. Authenticate user
  const user = await authenticateUser(req);
  if (!user || !user.hasPremiumAccess) {
    return res.status(403).json({ error: 'Access denied' });
  }

  // 2. Generate signed URL
  const signedUrl = cloudfront.getSignedUrl({
    url: 'https://d111111abcdef8.cloudfront.net/premium/video.mp4',
    expires: Math.floor(Date.now() / 1000) + 3600  // 1 hour
  });

  // 3. Return to client
  res.json({ url: signedUrl });
});
```

### Python Example (Testing/Development)

```python
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding
import base64
import json
from datetime import datetime, timedelta

# Load private key
with open('private-key.pem', 'rb') as f:
    private_key = serialization.load_pem_private_key(f.read(), password=None)

# Create policy
policy = {
    "Statement": [{
        "Resource": "https://d111111abcdef8.cloudfront.net/premium/video.mp4",
        "Condition": {
            "DateLessThan": {
                "AWS:EpochTime": int((datetime.now() + timedelta(hours=1)).timestamp())
            }
        }
    }]
}

# Sign and encode
policy_str = json.dumps(policy, separators=(',', ':'))
signature = private_key.sign(policy_str.encode(), padding.PKCS1v15(), hashes.SHA1())

# Build signed URL with CloudFront URL-safe base64
signed_url = (
    f"https://d111111abcdef8.cloudfront.net/premium/video.mp4"
    f"?Policy={base64.b64encode(policy_str.encode()).decode()}"
    f"&Signature={base64.b64encode(signature).decode()}"
    f"&Key-Pair-Id=APKA..."  # From terraform output
)
```

## Testing

### 1. Test without signature (should fail)

```bash
curl -I https://d111111abcdef8.cloudfront.net/premium/test.html
# Expected: HTTP/2 403 Forbidden
```

### 2. Generate and test with signature

```bash
cd trusted-key-groups

# Use the included Python script
python3 test-signed-url.py \
  "https://d111111abcdef8.cloudfront.net/premium/test.html" \
  "keys/private-key.pem" \
  "APKAXXXXXXXXXX"  # From terraform output: public_key_ids

# Test the signed URL
curl -I '<SIGNED_URL_FROM_OUTPUT>'
# Expected: NOT 403 (access granted)
```

## Key Rotation

To rotate keys without downtime:

1. Add new public key to the same key group in YAML:
   ```yaml
   video-streaming:
     public_keys:
       - name: "production-key-2024"  # Old key
       - name: "production-key-2025"  # New key
   ```

2. Deploy with `terraform apply`
3. Update your application to use the new private key
4. After confirming all requests use new key, remove old public key
5. Deploy again with `terraform apply`

## Security Best Practices

- **Private Keys**: Store in AWS Secrets Manager, Vault, or similar
- **Never Commit**: Add `*.pem` to `.gitignore`
- **Rotate Regularly**: Every 6-12 months recommended
- **Monitor Access**: Enable CloudWatch logs to detect unauthorized attempts
- **Use HTTPS Only**: Set `viewer_protocol_policy: https-only` for signed content
- **Short Expiration**: Use the shortest practical expiration time (1-24 hours)

## Troubleshooting

**403 with signed URL:**
- Verify Key-Pair-Id matches terraform output
- Check URL expiration timestamp
- Ensure signature encoding is correct (URL-safe base64)
- Verify private/public key pair match

**Signature mismatch:**
- Check policy JSON format (no extra whitespace)
- Verify base64 encoding is URL-safe
- Ensure private key matches public key in CloudFront

## Next Steps

- Integrate signed URL generation in your backend API
- Set up key rotation schedule
- Configure CloudWatch monitoring
- Test with your actual S3 content

## Complete Documentation

- [AWS CloudFront Signed URLs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html)
- [Trusted Key Groups](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html)
- [Main README](https://github.com/meries/terraform-aws-cloudfront/blob/main/README.md)
