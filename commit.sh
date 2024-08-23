#!/bin/bash

# Check if a commit message is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <commit_message>"
  exit 1
fi

# Use the first argument as the commit message
commit_message="$1"

# Add all changes to the staging area
git add .

# Commit the changes with the provided message
git commit -m "$commit_message"
git push