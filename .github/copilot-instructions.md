# AI Agent Instructions

This is a Terraform module that provisions AWS infrastructure for hosting static websites using S3 and CloudFront. Here's what you need to know to work effectively with this codebase:

## Project Architecture

- **Core Components**:

  - Private S3 bucket for storing static website content
  - CloudFront distribution for content delivery
  - Route53 DNS records (optional)
  - CloudWatch log groups for access logging

- **Security Model**:
  - S3 bucket is private, accessible only through CloudFront
  - Uses Origin Access Control (OAC) with sigv4 signing
  - Enforces HTTPS-only access via CloudFront

## Development Workflow

1. **Required Tools**:

   ```
   terraform 1.13.3
   tflint 0.59.1
   pre-commit 4.3.0
   ```

2. **Pre-commit Hooks**:
   - `terraform fmt` for consistent formatting
   - `terraform-docs` for README documentation
   - `terraform-tflint` for linting

## Key Files and Their Purpose

- `main.tf`: Core infrastructure definition
- `variables.tf`: Input variables with validation rules
- `outputs.tf`: Exposed module outputs
- `versions.tf`: Provider and version constraints

## Common Patterns

1. **Resource Naming**:

   ```hcl
   # Resources follow the pattern: {project}-{resource-type}-{env}
   "${var.project}-static-web-origin-${var.env}"
   ```

2. **CloudFront Configuration**:
   - Uses managed caching policy "CachingOptimized"
   - Supports optional CloudFront Functions via `function_association` variable
   - IPv6 enabled by default

## Integration Points

1. **Required Variables**:

   - `project`: Project name (lowercase, no spaces)
   - `env`: Deployment environment

2. **Optional Integrations**:
   - Custom domain support via `cdn_aliases` and `acm_cert_arn`
   - Route53 DNS integration via `route53_zone_id`
   - CloudFront Functions via `function_association`

## Documentation Practices

- Module documentation is maintained automatically by terraform-docs
- Any manual changes to the documentation section in README.md will be overwritten
