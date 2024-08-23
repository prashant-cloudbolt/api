#!/bin/bash

branch_name=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $branch_name"

case $branch_name in
multi_tenant_*)
    branch_suffix=$(echo "$branch_name" | sed 's/multi_tenant_//; s/-//g')
    ;;
mira-stage)
    branch_suffix="STAGE"
    ;;
*)
    echo "Unsupported branch: $branch_name"
    exit 1
    ;;
esac

# Convert suffix to uppercase
branch_suffix=$(tr '[:lower:]' '[:upper:]' <<< "$branch_suffix")
echo "branch_suffix=$branch_suffix"

# Get the latest release matching the branch suffix
latest_release=$(gh release list --limit 30 | grep -E "$branch_suffix" | sort -k4 -r | head -n 1 | awk '{print $1}')
echo "latest_release=$latest_release"

release_tag=$(gh release view $latest_release --json tagName -q ".tagName")
echo "release_tag=$release_tag"

# gitcommit_hash=$(git show $release_tag --pretty=format:"%H" --no-patch)
# echo "gitcommit_hash=$gitcommit_hash"

# Set your GitHub repository details and tag
REPO="api"
OWNER="prashant-cloudbolt"

# Get the commit hash
COMMIT_HASH=$(gh api repos/$OWNER/$REPO/git/ref/tags/$release_tag --jq '.object.sha')

echo "Commit Hash for tag $release_tag: $COMMIT_HASH"