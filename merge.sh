#!/bin/bash

git pull
git checkout multi_tenant_dev
git pull
git merge multi_tenant_stage
git push origin multi_tenant_dev
git checkout multi_tenant_stage
git push