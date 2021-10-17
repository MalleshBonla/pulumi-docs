#!/bin/bash

set -o errexit -o pipefail

source ./scripts/common.sh

# URL to the Pulumi conversion service.
export PULUMI_CONVERT_URL="${PULUMI_CONVERT_URL:-$(pulumi stack output --stack pulumi/tf2pulumi-service/production url)}"

export REPO_THEME_PATH="themes/default/"

printf "Copying prebuilt docs...\n\n"
make copy_static_prebuilt

printf "Running Hugo...\n\n"
if [ "$1" == "preview" ]; then
    export HUGO_BASEURL="http://$(origin_bucket_prefix)-$(build_identifier).s3-website.$(aws_region).amazonaws.com"
    GOGC=5 hugo --minify --templateMetrics -e "preview"
else
    GOGC=5 hugo --minify --templateMetrics -e production
fi

# Purge unused CSS.
yarn run minify-css

printf "Done!\n\n"
