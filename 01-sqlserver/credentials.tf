# ================================================================================
# FILE: credentials.tf
# ================================================================================
# PURPOSE:
#   Generates database credentials and stores them securely in Google Secret
#   Manager for use by dependent services and virtual machines.
#
# NOTES:
#   - Credentials are never hardcoded in Terraform configuration
#   - Passwords are generated at deploy time with strong entropy
#   - Secrets are retrieved at runtime via IAM-controlled access
# ================================================================================

# ================================================================================
# GENERATE RANDOM PASSWORD
# ================================================================================
# - Creates a strong, 24-character alphanumeric password
# - Special characters are disabled to avoid shell and tooling issues
# - Password value is consumed by Secret Manager only
# ================================================================================

resource "random_password" "sqlserver" {
  length  = 24
  special = false
}

# ================================================================================
# SECRET MANAGER: SQL SERVER CREDENTIALS
# ================================================================================
# - Defines a logical secret container in Google Secret Manager
# - Replication is handled automatically by Google
# - No secret material is stored at this stage
# ================================================================================

resource "google_secret_manager_secret" "sqlserver_secret" {
  secret_id = "sqlserver-credentials"

  replication {
    auto {}
  }
}

# ================================================================================
# SECRET VERSION: CREDENTIAL PAYLOAD
# ================================================================================
# - Stores the actual credential data as a JSON object
# - Includes static username and generated password
# - Enables secure retrieval by authorized workloads at runtime
# ================================================================================

resource "google_secret_manager_secret_version" "sqlserver_secret_version" {
  secret = google_secret_manager_secret.sqlserver_secret.id

  secret_data = jsonencode({
    username = "sqlserver"
    password = random_password.sqlserver.result
  })
}
