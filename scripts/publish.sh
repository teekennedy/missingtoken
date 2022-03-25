#!/usr/bin/env bash

# Get directory this script lives in
script_dir=$(dirname ${BASH_SOURCE[0]:-${(%):-%x}})
# Get repository root
repo_root=$(cd "$script_dir" && git rev-parse --show-toplevel)
# Set terraform directory relative to repo_root
terraform_dir="$repo_root/terraform"

s3_bucket=$(cd "$terraform_dir" && terraform output | awk '/^origin_bucket_name / {print $3}' | tr -d '"')

cd "$repo_root"

bundle exec jekyll build
aws s3 sync --delete _site/ "s3://$s3_bucket/"
