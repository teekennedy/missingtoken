# Missingtoken.net

The source for my Jekyll based, statically generated blog. Theme is based off of
[pixyll.com](http://www.pixyll.com).

## Getting started

### Installation

Install the required gems for this in a local bundle.

- Start by installing and initializing [rbenv](https://github.com/rbenv/rbenv).
- Check that you're running the version defined in this repository by running
  `rbenv version`. It should show that the version was set by the
  `.ruby-version` file in this repo.
- Run `bundle config .bundle/gems` to configure bundle to install gems locally
  for each repository. This is similar to virtualenv from python, although less
  explicit.
- Run `bundle install` to install all dependencies for generating this site.

### Serving locally

Then, start the Jekyll Server. I like to pass the `--watch` option so it
updates the generated HTML when I make changes.

```
$ bundle exec jekyll serve --watch
```

Now you can navigate to `localhost:4000` in your browser to see the site.

## Deployment to S3

TODO s3_website is broken, find an alternative.
