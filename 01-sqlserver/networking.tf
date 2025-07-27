# =================================================================================
# CREATE CUSTOM VPC NETWORK
# - This defines an isolated network environment for all SQL Server resources
# - Disables automatic subnet creation to enforce custom IP address planning
# =================================================================================
resource "google_compute_network" "sqlserver_vpc" {
  name                    = "sqlserver-vpc" # Name of the custom VPC
  auto_create_subnetworks = false           # Disable default subnet creation to retain control
}

# =================================================================================
# CREATE CUSTOM SUBNET
# - Defines a specific IP CIDR block inside the custom VPC
# - Hosts all compute and managed services (e.g., Postgres, pgweb)
# =================================================================================
resource "google_compute_subnetwork" "sqlserver_subnet" {
  name          = "sqlserver-subnet"                      # Subnet name
  ip_cidr_range = "10.0.0.0/24"                           # 256 IPs in this block
  region        = "us-central1"                           # Region must match instance placement
  network       = google_compute_network.sqlserver_vpc.id # Attach to the custom VPC above
}

# =================================================================================
# FIREWALL RULE: ALLOW INBOUND RDP (PORT 3389)
# - Enables remote admin access to VMs via RDP
# - Use source ranges and tags to secure access
# =================================================================================
resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"                             # Rule name
  network = google_compute_network.sqlserver_vpc.id # Attach to VPC

  allow {
    protocol = "tcp"    # Transmission protocol
    ports    = ["3389"] # RDP port
  }

  source_ranges = ["0.0.0.0/0"] # Open access — restrict to admin IPs for security
  target_tags   = ["allow-rdp"] # Scope to VMs that require RDP access
}

# =================================================================================
# GLOBAL INTERNAL IP ALLOCATION FOR PRIVATE SERVICE ACCESS
# - Creates an internal IP range used for service networking (e.g., mySQL)
# - Required for private services like Cloud SQL via Private Service Connect or VPC peering
# =================================================================================
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"                      # Unique name for the IP range
  purpose       = "VPC_PEERING"                           # Purpose must be set to VPC_PEERING
  address_type  = "INTERNAL"                              # Internal IP block, not external
  prefix_length = 16                                      # /16 = 65536 IPs (adjust to fit use)
  network       = google_compute_network.sqlserver_vpc.id # Attach to our custom VPC
}

# =================================================================================
# VPC PEERING CONNECTION FOR GOOGLE MANAGED SERVICES
# - Enables access to Google managed services (e.g., Cloud SQL) via internal IP
# - Must use service: servicenetworking.googleapis.com
# =================================================================================
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.sqlserver_vpc.id               # Custom VPC
  service                 = "servicenetworking.googleapis.com"                    # Required GCP service
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name] # Use previously created IP range

  # See https://github.com/hashicorp/terraform-provider-google/issues/16275 to explain this workaround
  provider = google-beta
}

