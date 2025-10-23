variable "project" {
  type        = string
  description = "Name of the project in lowercase without spaces, e.g., myproject"
}

variable "env" {
  type        = string
  description = "Deploy environment, e.g., prod, dev"
}

variable "cdn_aliases" {
  type    = list(string)
  default = []
}

variable "acm_cert_arn" {
  type        = string
  description = "ACM certificate to use if aliases are given. A CloudFront cert is used by default"
  default     = null

  validation {
    condition     = length(var.cdn_aliases) == 0 || var.acm_cert_arn != null
    error_message = "acm_cert_arn is required when cdn_aliases is provided"
  }
}

variable "route53_zone_id" {
  type        = string
  description = "Hosted zone where the CDN aliases will be added to"
  default     = null

  validation {
    condition     = length(var.cdn_aliases) == 0
    error_message = "A route53_zone_id is required to create the DNS records for the cdn_aliases"
  }
}

variable "function_association" {
  type        = any
  description = "Forwarded to the aws_cloudfront_distribution resource"
  default     = null
}


