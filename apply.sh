#!/bin/bash

# =================================================================================
# VALIDATE ENVIRONMENT
# - Ensures prerequisites are in place before proceeding
# =================================================================================

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

# =================================================================================
# DEPLOY MYSQL INFRASTRUCTURE
# - Initializes and applies Terraform configuration for Cloud SQL
# =================================================================================

cd 01-mysql || { echo "ERROR: Directory '01-mysql' not found."; exit 1; }
terraform init
terraform apply -auto-approve
cd ..

# =================================================================================
# VALIDATE THE BUILD
# =================================================================================

echo ""
./validate.sh