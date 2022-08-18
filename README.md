# Missingtoken.net

The source for my Jekyll based, statically generated blog. Theme is based off of
[pixyll.com](http://www.pixyll.com).

## Getting started

### Installation

Install the required gems for this in a local bundle.

- Start by installing and initializing [rbenv](https://github.com/rbenv/rbenv).
- Check that you're running the version defined in this repository by running `rbenv version`. It
  should show that the version was set by the `.ruby-version` file in this repo.
- Run `bundle config .bundle/gems` to configure bundle to install gems locally for each repository.
  This is similar to virtualenv from python, although less explicit.
- Run `bundle install` to install all dependencies for generating this site.
- Install ImageMagick to generate the site's favicons through [jekyll-favicon]. The [./favicon.svg]
  in this repo was generated specifically for ImageMagick's SVG processor. If you use any other
  software to view or generate the favicon it will look incorrect.
    - Make sure you __don't__ have Inkscape installed. It will be used instead of ImageMagick's
      built-in svg processor and will slow down jekyll build to ~10 seconds per page!

### Serving locally

Then, start the Jekyll Server. I like to pass the `--watch` option so it updates the generated HTML
when I make changes.

```
$ bundle exec jekyll serve --watch
```

Now you can navigate to `localhost:4000` in your browser to see the site.

### Adding posts

Start by creating a draft. Drafts show on the local Jekyll server but are not published:

`bundle exec jekyll draft "My New Post"`

If you need to rename it:

`bundle exec jekyll rename _drafts/my-new-post.md "My Renamed Post"`

When ready to publish:

## Deploying to S3

This repo uses [terraform-website-s3-cloudfront-route53] to deploy this static website to S3.

To setup, create a file with the extension `.auto.tfvars` in the `terraform` subdirectory and fill
out values for these variables:

```terraform
aws = {
  region = "us-west-2"
}
acm_certificate_arn              = <ARN of ACM certificate. Must be created in us-east-1 region!>
route53_zone_id                  = <ID of Route53 zone for the root domain>
root_domain                      = <Root domain name that the site will be served from>
redirect_subdomains              = ["www"]
duplicate_content_penalty_secret = <Some string to use as a shared secret between CloudFront and S3>
```

With the variables setup, change to the `terraform` subdirectory run through the usual terraform
init and apply steps:

```bash
cd terraform
terraform init
terraform apply
```

### Publishing the site

With the resources all setup, all that's left to do is build the site and copy the static files to
the origin s3 bucket. Run the `scripts/publish.sh` script to build the site and sync it to S3.

[jekyll-favicon]: https://github.com/afaundez/jekyll-favicon
[terraform-website-s3-cloudfront-route53]: https://github.com/teekennedy/terraform-website-s3-cloudfront-route53
