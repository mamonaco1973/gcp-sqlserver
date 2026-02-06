#!/bin/bash
# ================================================================================
# FILE: apply.sh
# ================================================================================
# PURPOSE:
#   Orchestrates the end-to-end deployment of the SQL Server environment.
#   Validates prerequisites, applies Terraform infrastructure, and verifies
#   the resulting build.
#
# NOTES:
#   - Script exits immediately on any error (fast-fail behavior)
#   - Assumes Terraform and required CLIs are already installed
#   - Must be executed from the project root directory
# ================================================================================

# Enable strict shell behavior:
#   -e  Exit immediately if a command fails
#   -u  Treat unset variables as an error
#   -o pipefail  Fail a pipeline if any command fails
set -euo pipefail

# ================================================================================
# VALIDATE ENVIRONMENT
# ================================================================================
# - Ensures all prerequisites (Terraform, credentials, etc.) are present
# - check_env.sh is expected to return non-zero on failure
# ================================================================================

./check_env.sh

# ================================================================================
# DEPLOY SQL SERVER INFRASTRUCTURE
# ================================================================================
# - Initializes Terraform providers and backend
# - Applies the SQL Server Cloud SQL stack non-interactively
# ================================================================================

cd 01-sqlserver
terraform init
terraform apply -auto-approve
cd ..

# ================================================================================
# VALIDATE BUILD RESULTS
# ================================================================================
# - Resolves and prints key outputs (Adminer URL, SQL endpoint, etc.)
# - Confirms the deployment is reachable and ready for use
# ================================================================================

echo ""
./validate.sh
