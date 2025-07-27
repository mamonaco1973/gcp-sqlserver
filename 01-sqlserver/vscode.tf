resource "google_compute_instance" "vscode_vm" {
  name         = "vscode-vm"     # Name of the VM instance
  machine_type = "e2-small"      # Low-cost instance type suitable for small workloads
  zone         = "us-central1-a" # Geographic zone for deployment (must match subnet region)

  # =================================================================================
  # BOOT DISK CONFIGURATION
  # - Uses latest Ubuntu 24.04 image
  # - Automatically initializes the boot disk from the specified image
  # =================================================================================
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_latest.self_link # Reference to latest Ubuntu image (see data block below)
    }
  }

  # =================================================================================
  # NETWORK INTERFACE CONFIGURATION
  # - Attaches instance to custom VPC and subnet
  # - Adds external IP via `access_config {}` for internet access
  # =================================================================================
  network_interface {
    network    = google_compute_network.sqlserver_vpc       # Connect to custom VPC
    subnetwork = google_compute_subnetwork.sqlserver_subnet # Attach to defined subnet
    access_config {}                                        # Enable public IP address
  }

  # =================================================================================
  # STARTUP SCRIPT INJECTION
  # - Loads external script template (e.g., ./scripts/phpmyadmin.sh.template)
  # - Replaces variables with actual values (MySQL password and endpoint)
  # ==================================================================
  metadata_startup_script = templatefile("./scripts/vscode.sh.template", {
    DBPASSWORD = random_password.sqlserver.result # Use generated SQL Server password
    DBUSER     = "sqlserver"                      # Static username for SQL Server
    DBENDPOINT = "sqlserver.internal.sqlserver-zone.local"
  })

  # =================================================================================
  # FIREWALL TAGS
  # - Enables association with firewall rules defined elsewhere (e.g., allow-ssh, allow-http)
  # - These tags are matched by `target_tags` in `google_compute_firewall` resources
  # =================================================================================
  tags = ["allow-ssh", "allow-http"]

  # =================================================================================
  # SERVICE ACCOUNT CONFIGURATION
  # - Attaches a service account to the VM for secure API access
  # - Uses client_email from parsed credentials file
  # - Scope: full access to all GCP APIs (cloud-platform)
  # =================================================================================
  service_account {
    email  = local.credentials.client_email # Reuse parsed email from credentials JSON
    scopes = ["cloud-platform"]             # Broad access — tighten for production use
  }

  # =================================================================================
  # DEPENDENCY MANAGEMENT
  # - Forces VM creation to wait for Cloud SQL instance to be ready
  # - Ensures startup script has a valid endpoint to connect to
  # =================================================================================
  #depends_on = [google_sql_database_instance.mysql] # Wait for MySQL instance to be created
}

# =================================================================================
# DATA SOURCE: UBUNTU LTS IMAGE
# - Dynamically fetches latest Ubuntu 24.04 LTS image
# - Ensures instance always boots from a stable and secure base image
# =================================================================================
data "google_compute_image" "ubuntu_latest" {
  family  = "ubuntu-2404-lts-amd64" # Image family ensures latest patch version is always used
  project = "ubuntu-os-cloud"       # Official Ubuntu image repository on GCP
}
