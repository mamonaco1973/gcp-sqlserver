# ================================================================================
# FILE: adminer.tf
# ================================================================================
# PURPOSE:
#   Provisions a lightweight Adminer virtual machine on Google Compute Engine
#   to provide browser-based access to the SQL Server database.
#
# NOTES:
#   - Intended for testing and administrative access, not production workloads
#   - VM is deployed with a public IP and protected via firewall tags
#   - Database credentials are injected via startup script templating
# ================================================================================

resource "google_compute_instance" "adminer_vm" {
  name         = "adminer-vm"
  machine_type = "e2-small"
  zone         = "us-central1-a"

  # ==============================================================================
  # BOOT DISK CONFIGURATION
  # - Initializes the VM using the latest Ubuntu 24.04 LTS image
  # - Image is dynamically resolved via a data source
  # ==============================================================================
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_latest.self_link
    }
  }

  # ==============================================================================
  # NETWORK INTERFACE CONFIGURATION
  # - Attaches the VM to the custom SQL Server VPC and subnet
  # - Assigns a public IP address for browser access to Adminer
  # ==============================================================================
  network_interface {
    network    = google_compute_network.sqlserver_vpc.id
    subnetwork = google_compute_subnetwork.sqlserver_subnet.id
    access_config {}
  }

  # ==============================================================================
  # STARTUP SCRIPT
  # - Renders and executes the Adminer installation script
  # - Injects database endpoint and credentials at boot time
  # ==============================================================================
  metadata_startup_script = templatefile(
    "./scripts/adminer.sh.template",
    {
      DBPASSWORD = random_password.sqlserver.result
      DBUSER     = "sqlserver"
      DBENDPOINT = "sqlserver.internal.sqlserver-zone.local"
    }
  )

  # ==============================================================================
  # FIREWALL TAGS
  # - Enables SSH and HTTP access via matching firewall rules
  # - Tags must align with target_tags in firewall resources
  # ==============================================================================
  tags = [
    "sqlserver-allow-ssh",
    "sqlserver-allow-http"
  ]

  # ==============================================================================
  # SERVICE ACCOUNT
  # - Attaches a service account for GCP API access
  # - Uses credentials parsed from the provided JSON file
  # ==============================================================================
  service_account {
    email  = local.credentials.client_email
    scopes = ["cloud-platform"]
  }

  # ==============================================================================
  # DEPENDENCIES
  # - Ensures SQL Server instance is provisioned before VM startup
  # - Guarantees database endpoint is available to the startup script
  # ==============================================================================
  depends_on = [
    google_sql_database_instance.sqlserver
  ]
}

# ================================================================================
# DATA SOURCE: UBUNTU LTS IMAGE
# ================================================================================
# Retrieves the latest Ubuntu 24.04 LTS image from the official GCP repository.
# Using an image family ensures security patches are applied automatically.
# ================================================================================

data "google_compute_image" "ubuntu_latest" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}
