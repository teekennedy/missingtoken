variable "aws" {
  type        = object({ region = string })
  description = "Common AWS related settings"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket used to store the static site resources."
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN for the ACM certificate used for https traffic to the website."
}

variable "route53_zone_id" {
  type        = string
  description = "ID of the Route53 zone for the root domain"
}

variable "root_domain" {
  type        = string
  description = "Root domain name for website"
  default     = "example.com"
}

variable "redirect_subdomains" {
  type        = list(string)
  description = "List of subdomains to redirect to the root domain"
  default     = []
}


variable "duplicate_content_penalty_secret" {
  type        = string
  sensitive   = true
  description = "Value that will be used in a custom header for a CloudFront distribution to gain access to the origin S3 bucket. Prevents web crawlers from indexing both the CloudFront distibution and the origin bucket, something that Google penalizes in search results."
  default     = null
}
