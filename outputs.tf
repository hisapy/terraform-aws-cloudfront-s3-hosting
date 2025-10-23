output "s3_bucket_name" {
  value       = aws_s3_bucket.origin.bucket
  description = "Name of the S3 bucket used for the site"
}

output "cloudfront_dist_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "CloudFront distribution domain name"
}

output "cloudfront_dist_aliases" {
  value       = aws_cloudfront_distribution.cdn.aliases
  description = "CloudFront distribution aliases"
}

output "cloudfront_dist_id" {
  value       = aws_cloudfront_distribution.cdn.id
  description = "CloudFront distribution id"
}

output "cloudfront_hosted_zone_id" {
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
  description = "CloudFront distribution hosted_zone_id"
}
