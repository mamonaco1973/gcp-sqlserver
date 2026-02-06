#!/bin/bash
# ================================================================================
# FILE: validate.sh
# ================================================================================
# Resolves and prints the Adminer endpoint and the SQL Server DNS endpoint.
# Also waits for Adminer to become reachable before returning success.
#
# OUTPUT (SUMMARY):
#   - Adminer URL
#   - SQL Server hostname
# ================================================================================
#
# This script is intended to be run after a successful Terraform apply.
# It validates that the Adminer UI is reachable and prints the internal
# SQL Server hostname used by clients on the VPC.
# ================================================================================

# Enable strict shell behavior:
#   -e  Exit immediately on error
#   -u  Treat unset variables as errors
#   -o pipefail  Fail pipelines if any command fails
set -euo pipefail

# ================================================================================
# CONFIGURATION
# ================================================================================

GCP_ZONE="us-central1-a"
ADMINER_INSTANCE_NAME="adminer-vm"
ADMINER_PATH="/adminer"

SQLSERVER_DNS="sqlserver.internal.sqlserver-zone.local"

MAX_ATTEMPTS=30
SLEEP_SECONDS=30

# ================================================================================
# RESOLVE ADMINER PUBLIC IP
# ================================================================================

ADMINER_IP="$(gcloud compute instances describe "${ADMINER_INSTANCE_NAME}" \
  --zone="${GCP_ZONE}" \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"

# Exit if Adminer IP is empty or null.
if [[ -z "${ADMINER_IP}" ]]; then
  echo "ERROR: Failed to resolve Adminer public IP for ${ADMINER_INSTANCE_NAME}."
  exit 1
fi

ADMINER_URL="http://${ADMINER_IP}${ADMINER_PATH}"
echo "NOTE: Adminer URL is ${ADMINER_URL}"

# ================================================================================
# WAIT FOR ADMINER TO BECOME AVAILABLE
# ================================================================================

echo "NOTE: Waiting for Adminer to become available at ${ADMINER_URL}..."

ATTEMPT=1
until curl -s --head --fail "${ADMINER_URL}" > /dev/null; do
  if [[ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]]; then
    echo "ERROR: Adminer did not become available after ${MAX_ATTEMPTS} attempts."
    exit 1
  fi

  echo "WARNING: Adminer not yet reachable. Retrying in ${SLEEP_SECONDS}s..."
  sleep "${SLEEP_SECONDS}"
  ATTEMPT=$((ATTEMPT + 1))
done

# ================================================================================
# FINAL OUTPUT (SUMMARY)
# ================================================================================

echo ""
echo "================================================================================"
echo "BUILD OUTPUTS"
echo "================================================================================"
echo "Adminer URL:           ${ADMINER_URL}"
echo "SQL Server hostname:   ${SQLSERVER_DNS}"
echo "================================================================================"
