#!/bin/bash
# ================================================================================
# FILE: destroy.sh
# ================================================================================
# PURPOSE:
#   Tears down the SQL Server environment in a controlled order.
#   Performs an explicit Cloud SQL instance deletion followed by a full
#   Terraform destroy of all remaining infrastructure.
#
# NOTES:
#   - Script exits immediately on any error (fast-fail behavior)
#   - Must be executed from the project root directory
#   - Destruction is irreversible; data will be permanently lost
# ================================================================================

# Enable strict shell behavior:
#   -e  Exit immediately if a command fails
#   -u  Treat unset variables as an error
#   -o pipefail  Fail a pipeline if any command fails
set -euo pipefail

# ================================================================================
# VALIDATE ENVIRONMENT
# ================================================================================
# - Ensures required tooling, credentials, and configuration are present
# - check_env.sh must return non-zero on failure
# ================================================================================

./check_env.sh

# ================================================================================
# DESTROY CLOUD SQL INSTANCE
# ================================================================================
# - Explicitly deletes the Cloud SQL SQL Server instance
# - Avoids dependency and ordering issues during Terraform destroy
# ================================================================================

gcloud sql instances delete sqlserver-instance --quiet

# ================================================================================
# DESTROY TERRAFORM INFRASTRUCTURE
# ================================================================================
# - Initializes Terraform to ensure providers and state are available
# - Destroys all remaining resources defined in the module
# ================================================================================

cd 01-sqlserver
terraform init
terraform destroy -auto-approve
cd ..
