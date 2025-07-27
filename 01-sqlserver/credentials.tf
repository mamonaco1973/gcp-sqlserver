# =================================================================================
# GENERATE RANDOM PASSWORD FOR SQLSERVER USER
# - Securely generates a 24-character alphanumeric password
# - Special characters are disabled for better compatibility with scripts, shell, and tooling
# - Output is used for secure service authentication (not stored in plaintext in code)
# =================================================================================
resource "random_password" "sqlserver" {
  length  = 24    # Strong entropy: 24-character password
  special = false # Disable special characters to avoid shell/script issues
}

# =================================================================================
# CREATE SECRET IN GOOGLE SECRET MANAGER
# - Securely stores the Postgres credentials (username + generated password)
# - Enables controlled access via IAM policies, instead of hardcoding credentials
# - Replication is managed by Google (multi-region/high availability by default)
# =================================================================================
resource "google_secret_manager_secret" "sqlserver_secret" {
  secret_id = "sqlserver-credentials" # Logical name for this secret

  replication {
    auto {} # Use default replication policy — ensures global durability and availability
  }
}

# =================================================================================
# ADD SECRET VERSION WITH CREDENTIAL DATA
# - Binds the actual secret content (JSON) to the secret defined above
# - Stores the username and securely generated password as a JSON object
# - Enables service accounts, VMs, or workloads to fetch credentials securely at runtime
# =================================================================================
resource "google_secret_manager_secret_version" "sqlserver_secret_version" {
  secret = google_secret_manager_secret.sqlserver_secret.id # Target the parent secret
  secret_data = jsonencode({                                # Encode structured credentials
    username = "sqlserver"                                  # Static username
    password = random_password.sqlserver.result             # Dynamic password (from above)
  })
}
