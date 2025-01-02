#!/bin/bash

# Upload Feature Flag file to S3 bucket

set -e

# Get the stack name, bucket name, and feature flag file name from positional arguments
BUCKET_NAME=$1
FILE_NAME=$2
FEATURE_FLAG_PATH=$3

if [[ -z "$BUCKET_NAME" ]]; then
  echo "Error: Bucket name is required."
  exit 1
fi

if [[ -z "$FILE_NAME" ]]; then
  echo "Error: Feature flag file name is required."
  exit 1
fi

if [[ -z "$FEATURE_FLAG_PATH" ]]; then
  echo "Error: Feature flag path is required."
  exit 1
fi

# Function to calculate the MD5 checksum of a local file
calculate_md5() {
  local file_path=$1
  md5sum "$file_path" | awk '{ print $1 }'
}

# Function to get the MD5 checksum of a file in S3
get_s3_md5() {
  local bucket_name=$1
  local file_key=$2
  aws s3api head-object --bucket "$bucket_name" --key "$file_key" --query "ETag" --output text | tr -d '"'
}

# Calculate MD5 checksums for local files
local_feature_flag_md5=$(calculate_md5 "$FEATURE_FLAG_PATH/$FILE_NAME")

# Get MD5 checksums for files in S3
s3_feature_flag_md5=$(get_s3_md5 "$BUCKET_NAME" "$FILE_NAME")

# Upload files only if they have changed
if [ "$local_feature_flag_md5" != "$s3_feature_flag_md5" ]; then
  aws s3 cp "$FEATURE_FLAG_PATH/$FILE_NAME" "s3://$BUCKET_NAME/"
  new_feature_flag_version_id=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --prefix "$FILE_NAME" --query "Versions[?IsLatest].VersionId" --output text)
  echo "Uploaded $  /$FILE_NAME with version ID: $new_feature_flag_version_id"
  echo "::set-output name=feature_flag_version_id::$new_feature_flag_version_id"
else
  feature_flag_version_id=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --prefix "$FILE_NAME" --query "Versions[?IsLatest].VersionId" --output text)
  echo "No changes detected in $FILE_NAME. Skipping upload. Current version ID: $feature_flag_version_id"
fi
