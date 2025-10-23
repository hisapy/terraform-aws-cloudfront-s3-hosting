# Terraform AWS CloudFront S3 hosting

Use this module to provision a CloudFront distribution to serve an static website or assets from a private S3 bucket, along with policies and related resources.

The `default_root_object` is expected to be `"index.html"` but a [function_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#function_association-1) can be provided to customize requests handling.

Check the [.tool-versions](./.tool-versions) file to see the tools and the versions used in this project.

## Website Deployment

The _basic_ steps to deploy an static website with this setup:

1. Build your site
2. Upload/sync your new build to S3
3. Invalidate CloudFront cache

For example:

```bash
# Build (outputs to the dist directory)
npm run build

# Sync to the S3 bucket my-web-bucket
aws s3 sync ./dist s3://my-web-bucket/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_DIST_ID \
  --paths "/*"
```

**NOTICE:** The Terraform documentation in this README is added by [terraform-docs](https://terraform-docs.io) running as a pre-commit hook, see the [.pre-commit-config.yaml](./.pre-commit-config.yaml) file.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.13.3  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.15 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 6.15 |

## Resources

| Name                                                                                                                                                            | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudfront_distribution.cdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                          | resource    |
| [aws_cloudfront_origin_access_control.oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control)        | resource    |
| [aws_cloudwatch_log_delivery.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery)                         | resource    |
| [aws_cloudwatch_log_delivery_destination.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_destination) | resource    |
| [aws_cloudwatch_log_delivery_source.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_delivery_source)           | resource    |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                               | resource    |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                           | resource    |
| [aws_s3_bucket.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                   | resource    |
| [aws_s3_bucket_policy.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                     | resource    |
| [aws_cloudfront_cache_policy.optimize](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy)                  | data source |
| [aws_iam_policy_document.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                            | data source |

## Inputs

| Name                                                                                          | Description                                                                       | Type           | Default | Required |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_acm_cert_arn"></a> [acm_cert_arn](#input_acm_cert_arn)                         | ACM certificate to use if aliases are given. A CloudFront cert is used by default | `string`       | `null`  |    no    |
| <a name="input_cdn_aliases"></a> [cdn_aliases](#input_cdn_aliases)                            | n/a                                                                               | `list(string)` | `[]`    |    no    |
| <a name="input_env"></a> [env](#input_env)                                                    | Deploy environment, e.g., prod, dev                                               | `string`       | n/a     |   yes    |
| <a name="input_function_association"></a> [function_association](#input_function_association) | Forwarded to the aws_cloudfront_distribution resource                             | `any`          | `null`  |    no    |
| <a name="input_project"></a> [project](#input_project)                                        | Name of the project in lowercase without spaces, e.g., myproject                  | `string`       | n/a     |   yes    |
| <a name="input_route53_zone_id"></a> [route53_zone_id](#input_route53_zone_id)                | Hosted zone where the CDN aliases will be added to                                | `string`       | `null`  |    no    |

## Outputs

| Name                                                                                                                 | Description                             |
| -------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| <a name="output_cloudfront_dist_aliases"></a> [cloudfront_dist_aliases](#output_cloudfront_dist_aliases)             | CloudFront distribution aliases         |
| <a name="output_cloudfront_dist_domain_name"></a> [cloudfront_dist_domain_name](#output_cloudfront_dist_domain_name) | CloudFront distribution domain name     |
| <a name="output_cloudfront_dist_id"></a> [cloudfront_dist_id](#output_cloudfront_dist_id)                            | CloudFront distribution id              |
| <a name="output_cloudfront_hosted_zone_id"></a> [cloudfront_hosted_zone_id](#output_cloudfront_hosted_zone_id)       | CloudFront distribution hosted_zone_id  |
| <a name="output_s3_bucket_name"></a> [s3_bucket_name](#output_s3_bucket_name)                                        | Name of the S3 bucket used for the site |

<!-- END_TF_DOCS -->
