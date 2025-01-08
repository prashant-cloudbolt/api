#!/bin/bash

branch_name="CP-2104-BE-Policy-Status-Add-Policy-Name-in-Action-Detail-Api"

if [[ "$branch_name" =~ (CP-[0-9]+) ]]; then
  echo "cp_code=${BASH_REMATCH[1]}"
else
  echo "cp_code=default"
fi