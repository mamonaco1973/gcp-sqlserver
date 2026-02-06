# ================================================================================
# FILE: main.tf
# ================================================================================
# PURPOSE:
#   Defines Terraform provider requirements, configures the Google providers,
#   and parses service account credentials into reusable local variables.
#
# NOTES:
#   - This project reads a service account key from ../credentials.json
#   - Do NOT commit credentials.json to source control
#   - Provider configuration is centralized here for consistent behavior
# ================================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>4"
    }
  }
}

# ================================================================================
# PROVIDER: GOOGLE
# ================================================================================
# - Primary GCP provider used by most resources
# - Project is derived dynamically from the decoded credentials file
# - Credentials are loaded from a local service account key JSON
# ================================================================================

provider "google" {
  project     = local.credentials.project_id
  credentials = file("../credentials.json")
}

# ================================================================================
# PROVIDER: GOOGLE-BETA
# ================================================================================
# - Beta provider required for select resources and preview features
# - Uses the same project and credentials as the primary provider
# ================================================================================

provider "google-beta" {
  project     = local.credentials.project_id
  credentials = file("../credentials.json")
}

# ================================================================================
# LOCALS: SERVICE ACCOUNT CREDENTIALS
# ================================================================================
# - Decodes the service account JSON key into a usable object
# - Exposes commonly referenced fields (project_id, client_email)
# - Keeps downstream resources free of hardcoded identifiers
# ================================================================================

locals {
  credentials = jsondecode(file("../credentials.json"))

  service_account_email = local.credentials.client_email
}
