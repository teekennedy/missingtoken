#!/usr/bin/env bash

terraform_dir=$(dirname ${BASH_SOURCE[0]:-${(%):-%x}})
cd "$terraform_dir"

s3_bucket=$(terraform output | awk '/^origin_bucket_name / {print $3}' | tr -d '"')

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

bundle exec jekyll build
aws s3 sync --delete _site/ "s3://$s3_bucket/"
