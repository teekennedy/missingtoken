#!_env27/bin/python

# This script manages Let's Encrypt certificates based on information stored in
# s3_website.yml. If you use S3 Website [1] to manage your static site, you
# already have many of the settings needed to run certbot's S3 plugin [2].

# Prerequisites: Run `scripts/install_aws_tools.sh` from the project root.
# Usage: 

# [1] https://github.com/laurilehmijoki/s3_website
# [2] https://github.com/dlapiduz/certbot-s3front

import yaml
from os import environ
from subprocess import Popen, PIPE

s3_yaml_file = open('s3_website.yml', 'r')
s3_yaml = yaml.load(s3_yaml_file)

certbot_env = environ.copy()
certbot_env['AWS_ACCESS_KEY_ID'] = s3_yaml['s3_id']
certbot_env['AWS_SECRET_ACCESS_KEY'] = s3_yaml['s3_secret']

command = [
        '_env27/bin/certbot', '--non-interactive', '--agree-tos', '--email',
        s3_yaml['le_account_email'],
        '-a', 'certbot-s3front:auth',
        '--certbot-s3front:auth-s3-bucket',
        s3_yaml['s3_bucket'],
        '--certbot-s3front:auth-s3-region',
        s3_yaml['s3_endpoint'],
        '-i', 'certbot-s3front:installer',
        '--certbot-s3front:installer-cf-distribution-id',
        s3_yaml['cloudfront_distribution_id'],
        '--domain', 'missingtoken.net',
    ]

certbot_process = Popen(command, env=certbot_env, stdout=PIPE, stderr=PIPE)
certbot_process.wait()

print(certbot_process.stdout.read())
print(certbot_process.stderr.read())
