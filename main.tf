# AWS infra for a static website stored in a S3 bucket and served from CloudFront

## S3 ##

resource "aws_s3_bucket" "origin" {
  # TODO: maybe make this configurable adding it to variables.tf 
  bucket = "${var.project}-static-web-origin-${var.env}"
}

resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.bucket
  policy = data.aws_iam_policy_document.origin.json
}

# See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "origin" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.origin.arn}/*",
      "${aws_s3_bucket.origin.arn}/en/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

## CloudFront ##

locals {
  s3_origin_id = "${var.project}-static-web-s3"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "optimize" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} static website ${var.env}"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = var.cdn_aliases

  viewer_certificate {
    acm_certificate_arn            = var.acm_cert_arn
    cloudfront_default_certificate = var.acm_cert_arn == null
    ssl_support_method             = var.acm_cert_arn == null ? null : "sni-only"
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = data.aws_cloudfront_cache_policy.optimize.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    dynamic "function_association" {
      for_each = coalesce(var.function_association, [])

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

## Route53 (required to point the CDN aliases to it) ##

resource "aws_route53_record" "this" {
  for_each = toset(var.cdn_aliases)
  zone_id  = var.route53_zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}


## CloudWatch (logging) ##

locals {
  log_group_name = "${var.project}-${var.env}-static-web-logs"
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.log_group_name
}

resource "aws_cloudwatch_log_delivery_source" "this" {
  name         = local.log_group_name
  resource_arn = aws_cloudfront_distribution.cdn.arn
  log_type     = "ACCESS_LOGS"
}

resource "aws_cloudwatch_log_delivery_destination" "this" {
  name = local.log_group_name

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.this.arn
  }
}

resource "aws_cloudwatch_log_delivery" "this" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.this.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.this.arn
}


