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

latest_version=$(gh release list --limit 30 | grep -E "$branch_suffix" | sort -k4 -r | head -n 1 | awk '{print $1}' | sed 's/.*v//')
echo "latest_version=$latest_version"


version_fragment=$(gh pr list -R prashant-cloudbolt/api --state merged | head -n 1 | awk '{print $(NF-2)}' | cut -d"/" -f1)
echo "version_fragment=$version_fragment"

# Set version fragment based on value:
if [[ "$version_fragment" == "bug" ]]; then
    version_fragment="bug"
    echo "Version fragment set to: bug"
elif [[ "$version_fragment" == "major" ]]; then
    version_fragment="major"
    echo "Version fragment set to: major"
else
    version_fragment="feature"
    echo "No matching fragment found, using default: feature"
fi

echo "Version fragment: $version_fragment"