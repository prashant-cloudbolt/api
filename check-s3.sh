#!/bin/bash

BUCKET_NAME="github-feature-flag-json-s3-development-12345"
echo "BUCKET_NAME=$BUCKET_NAME"
LATEST_VERSION=$(aws s3 ls s3://"$BUCKET_NAME"/ | grep feature_flag_v | sort | tail -n 1 | awk '{print $4}')


# Check if LATEST_VERSION has a value or is empty
if [ -z "$LATEST_VERSION" ]; then
  echo "No version found. LATEST_VERSION is empty."
else
  echo "Latest version: $LATEST_VERSION"
fi