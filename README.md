# Missingtoken.net

The source for my Jekyll based, statically generated blog. Theme is based off
of [pixyll.com](http://www.pixyll.com).

## Getting started

### Installation

I highly recommend installing the required gems for this in a local bundle.

- Start by installing and initializing [rbenv](https://github.com/rbenv/rbenv).
- Check that you're running the version defined in this repository by running
  `rbenv version`. It should show that the version was set by the
  `.ruby-version` file in this repo.
- Run `bundle config .bundle/gems` to configure bundle to install gems locally
  for each repository. This is similar to virtualenv from python, although less
  explicit.
- Run `bundle install` to install all dependencies for generating this site.

### Serving locally

Then, start the Jekyll Server. I always like to give the `--watch` option so it
updates the generated HTML when I make changes.

```
$ bundle exec jekyll serve --watch
```

Now you can navigate to `localhost:4000` in your browser to see the site.

## Deployment to S3

If you want to deploy this site to AWS S3, install
[`s3_website`](https://github.com/laurilehmijoki/s3_website). Follow the
instructions for installation and configuration, then deploy with:

<<<<<<< HEAD
```
s3_website push
```

You can use the `--force` option to force update assets, which is necessary
when modifying HTTP headers like `cache_control`.

## Using Let's Encrypt for certificate management on AWS

### Setup

- Run `./scripts/install_aws_tools.sh` from the project root directory to
  install AWS tools.
- Make sure you have an `s3_website.yml` created and configured from the
  (#deployment-to-s3) section.

### Creating or updating the certificate

Run `./scripts/s3_le_cert.py` as root. It will load the configuration and
secrets from `s3_website.yml` and pass them through to certbot.
