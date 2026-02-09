# ================================================================================
# FILE: networking.tf
# ================================================================================
# PURPOSE:
#   Creates the network foundation for the SQL Server deployment:
#     - Custom VPC and subnet
#     - Firewall rules for Adminer (HTTP) and administration (SSH)
#     - Private Service Access IP allocation and Service Networking connection
#
# NOTES:
#   - auto_create_subnetworks is disabled to enforce explicit IP planning
#   - HTTP is intentionally open in this lab build; restrict in production
#   - Private Service Access is required for private IP Cloud SQL connectivity
# ================================================================================

# ================================================================================
# VPC: CUSTOM NETWORK
# ================================================================================
# - Defines an isolated VPC for all SQL Server resources
# - Disables automatic subnet creation to enforce custom IP planning
# ================================================================================

resource "google_compute_network" "sqlserver_vpc" {
  name                    = "sqlserver-vpc"
  auto_create_subnetworks = false
}

# ================================================================================
# SUBNET: SQL SERVER SUBNET
# ================================================================================
# - Defines the CIDR range for workloads in the SQL Server VPC
# - Region must align with VM placement and regional services
# ================================================================================

resource "google_compute_subnetwork" "sqlserver_subnet" {
  name          = "sqlserver-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.sqlserver_vpc.id
}

# ================================================================================
# FIREWALL: ALLOW HTTP (PORT 80)
# ================================================================================
# - Enables browser access to Adminer (or other web UIs) on port 80
# - Currently open to the internet; tighten source_ranges in production
# ================================================================================

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.sqlserver_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

# ================================================================================
# FIREWALL: ALLOW SSH (PORT 22)
# ================================================================================
# - Enables administrative SSH access to select VMs
# - Scoped using target tags; restrict source_ranges for production use
# ================================================================================

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.sqlserver_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# ================================================================================
# PRIVATE SERVICE ACCESS: RESERVED IP RANGE
# ================================================================================
# - Allocates an internal CIDR for Google managed services via VPC peering
# - Required for private IP Cloud SQL connectivity
# ================================================================================

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "mysql-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.sqlserver_vpc.id
}

# ================================================================================
# PRIVATE SERVICE ACCESS: SERVICE NETWORKING CONNECTION
# ================================================================================
# - Establishes the peering connection to servicenetworking.googleapis.com
# - Uses the reserved IP range allocated above
# - Uses google-beta provider due to known provider behavior/workarounds
# ================================================================================

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.sqlserver_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  provider = google-beta
}
