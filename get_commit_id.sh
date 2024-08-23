#!/bin/bash

latest_release=$(curl -s https://api.github.com/repos/prashant-cloudbolt/api/releases/latest)
echo "latest_release=$latest_release"
commit_id=$(echo $latest_release | jq -r '.target_commitish')
echo "The commit ID for the latest release is: $commit_id"