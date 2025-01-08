#!/bin/bash

branch_name="feature/CP-2104-BE-Policy-Status-Add-Policy-Name-in-Action-Detail-Api"
PATTERN="(CP-[0-9]+)"

echo "branch_name : $branch_name"

if [[ $branch_name =~ $PATTERN ]]; then
  jira_story="${BASH_REMATCH[1]}"
  random_chars=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
  feature_flag_s3_bucket="${jira_story}-feature-flag-s3-${random_chars}"
  echo "feature_flag_s3_bucket=$feature_flag_s3_bucket"
else
  echo "No JIRA story found in the branch name"
fi


feature_flag_s3_bucket_slugified=$(
  echo "$feature_flag_s3_bucket" | 
  tr '[:upper:]' '[:lower:]' | 
  tr -s '[:space:]' '-' | 
  tr -cd '[:alnum:]-' | 
  sed -E 's/-+$//'
)

echo "FeatureFlag S3 bucket Slugified: '$feature_flag_s3_bucket_slugified'"