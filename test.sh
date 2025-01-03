#!/bin/bash

# Define color codes for output messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BUCKET_NAME="cp-2117-feature-flag-bucket"
REGION="us-west-2"

# Check if the bucket exists
echo -e "${YELLOW}Checking if S3 bucket '$BUCKET_NAME' exists...${NC}"
bucket_status=$(aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>&1)

if echo "$bucket_status" | grep -q 'Not Found'; then
  echo -e "${YELLOW}Bucket '$BUCKET_NAME' not found. It may already be deleted.${NC}"
  exit 0
fi

# Bucket exists; proceed to empty and delete
echo -e "${YELLOW}Emptying bucket '$BUCKET_NAME'...${NC}"

# Check if the bucket has versioning enabled
versioning_status=$(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --region "$REGION" --query "Status" --output text)
if [[ "$versioning_status" == "Enabled" ]]; then
  echo -e "${YELLOW}Bucket '$BUCKET_NAME' has versioning enabled. Deleting all object versions...${NC}"

  # Fetch and delete all object versions
  VERSIONS=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --region "$REGION" --query "Versions[].{Key:Key,VersionId:VersionId}" --output text)
  if [ -n "$VERSIONS" ]; then
    while IFS=$'\t' read -r KEY VERSION_ID; do
      echo "Deleting version: $VERSION_ID for object: $KEY"
      aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION_ID"
    done <<< "$VERSIONS"
  fi

  # List and delete all delete markers
  echo "Deleting all delete markers from bucket: $BUCKET_NAME"
  DELETE_MARKERS=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query "DeleteMarkers[].{Key:Key,VersionId:VersionId}" --output text)

  if [ -n "$DELETE_MARKERS" ]; then
    while IFS=$'\t' read -r KEY VERSION_ID; do
      echo "Deleting delete marker: $VERSION_ID for object: $KEY"
      aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION_ID"
    done <<< "$DELETE_MARKERS"
  fi

else
  echo -e "${YELLOW}Bucket '$BUCKET_NAME' does not have versioning enabled. Deleting objects recursively...${NC}"
  aws s3 rm "s3://$BUCKET_NAME" --recursive
fi

# Delete the bucket
echo -e "${YELLOW}Deleting bucket '$BUCKET_NAME'...${NC}"
if aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"; then
  echo -e "${GREEN}Bucket '$BUCKET_NAME' deleted successfully.${NC}"
else
  echo -e "${RED}Failed to delete bucket '$BUCKET_NAME'.${NC}"
  exit 1
fi
