# #!/bin/bash

#-------------------------------------------------------------------------------
# Output adminer URL and sqlserver DNS name
#-------------------------------------------------------------------------------

ADMINER_IP=$(gcloud compute instances describe adminer-vm \
   --zone=us-central1-a \
   --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

echo "NOTE: Adminer running at http://$ADMINER_IP"

# Wait until the Adminer URL is reachable (HTTP 200 or similar)
echo "NOTE: Waiting for Adminer to become available at http://$ADMINER_IP ..."

# Max attempts (optional)
MAX_ATTEMPTS=30
ATTEMPT=1

until curl -s --head --fail "http://$ADMINER_IP/adminer" > /dev/null; do
   if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
     echo "ERROR: Adminer did not become available after $MAX_ATTEMPTS attempts."
     exit 1
   fi
   echo "WARNING: Adminer not yet reachable. Retrying in 30 seconds..."
   sleep 30
   ATTEMPT=$((ATTEMPT+1))
done

SQLSERVER_DNS="sqlserver.internal.sqlserver-zone.local"
echo "NOTE: Hostname for SQL Server is \"$SQLSERVER_DNS\""

#-------------------------------------------------------------------------------
# END OF SCRIPT
#-------------------------------------------------------------------------------
