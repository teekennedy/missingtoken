terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7"
    }
  }

  required_version = ">= 1.1.7"
}


provider "aws" {
  profile = "default"
  region  = var.aws.region
}

module "site-main" {
  source = "github.com/teekennedy/terraform-website-s3-cloudfront-route53//site-main"

  region              = var.aws.region
  domain              = var.root_domain
  bucket_name         = "site-missingtoken-net-us-west-2"
  acm-certificate-arn = var.acm_certificate_arn
  # Value that will be used in a custom header for a CloudFront distribution to gain access to the
  # origin S3 bucket. Prevents web crawlers from indexing both the CloudFront distibution and the
  # origin bucket, something that Google penalizes in search results.
  duplicate-content-penalty-secret = var.duplicate_content_penalty_secret
  # HTTPS security policy used by CloudFront
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html#secure-connections-supported-ciphers
  minimum_client_tls_protocol_version = "TLSv1.2_2021"
  # Price class that limits the edge locations that the content will be available from.
  # https://aws.amazon.com/cloudfront/pricing/
  price_class = "PriceClass_200"
  # Path and code for when 404 page.
  not-found-response-path = "/404.html"
  not-found-response-code = 404
  # Enable IPv6 on CloudFront distribution
  ipv6 = true
}

module "dns-alias" {
  source = "github.com/teekennedy/terraform-website-s3-cloudfront-route53//r53-alias"

  domain             = var.root_domain
  target             = module.site-main.website_cdn_hostname
  cdn_hosted_zone_id = module.site-main.website_cdn_zone_id
  route53_zone_id    = var.route53_zone_id
}

module "site-redirect" {
  source                           = "github.com/teekennedy/terraform-website-s3-cloudfront-route53//site-redirect"
  for_each                         = toset(var.redirect_subdomains)
  bucket_name                      = replace("${join(".", [each.value, var.root_domain])}-${var.aws.region}", ".", "-")
  region                           = var.aws.region
  domain                           = join(".", [each.value, var.root_domain])
  target                           = var.root_domain
  duplicate-content-penalty-secret = var.duplicate_content_penalty_secret
  acm-certificate-arn              = var.acm_certificate_arn
}

module "dns-cname" {
  source          = "github.com/skyscrapers/terraform-website-s3-cloudfront-route53//r53-cname"
  for_each        = toset(var.redirect_subdomains)
  domain          = join(".", [each.value, var.root_domain])
  target          = var.root_domain
  route53_zone_id = var.route53_zone_id
}
