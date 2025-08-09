# =================================================================================
# CLOUD SQL INSTANCE: SQL SERVER 2022 (STANDARD)
# =================================================================================
resource "google_sql_database_instance" "sqlserver" {
  name             = "sqlserver-instance"             # Instance ID (unique per project)
  database_version = "SQLSERVER_2022_STANDARD"        # Engine/edition
  region           = "us-central1"                    # Deployment region
  root_password    = random_password.sqlserver.result # SQL admin password (store securely)

  settings {
    tier = "db-custom-2-7680" # 2 vCPU / 7.5 GB (adjust to workload)

    ip_configuration {
      ipv4_enabled    = false                                          # Disable public IPv4
      private_network = google_compute_network.sqlserver_vpc.self_link # Use Private IP on this VPC
    }

    backup_configuration {
      enabled = true # Enable automated backups (retain defaults)
    }

    maintenance_window {
      day          = 7        # Sunday
      hour         = 3        # 03:00 local region time
      update_track = "stable" # Stable channel for patching
    }

    activation_policy = "ALWAYS" # Required for SQL Server licensing
    availability_type = "ZONAL"  # Single-zone (change to REGIONAL for HA)
  }

  deletion_protection = false # Allow terraform destroy (enable in prod)

  depends_on = [null_resource.wait_for_vpc_peering] # Ensure peering is ready before create
}

# =================================================================================
# PRIVATE DNS ZONE FOR SQL SERVER
# =================================================================================
resource "google_dns_managed_zone" "private_dns" {
  name       = "internal-sqlserver-zone"        # Managed zone name
  dns_name   = "internal.sqlserver-zone.local." # Zone FQDN (trailing dot required)
  visibility = "private"                        # Private to selected networks

  private_visibility_config {
    networks {
      network_url = google_compute_network.sqlserver_vpc.id # Scope zone to the SQL VPC
    }
  }

  description = "Private DNS zone for internal SQL Server database"
}

# =================================================================================
# PRIVATE A RECORD: sqlserver.internal.sqlserver-zone.local
# =================================================================================
resource "google_dns_record_set" "sqlserver_dns" {
  name         = "sqlserver.internal.sqlserver-zone.local." # Record FQDN (trailing dot required)
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private_dns.name
  rrdatas      = [google_sql_database_instance.sqlserver.private_ip_address] # Cloud SQL Private IP
}

# =================================================================================
# WAIT FOR VPC PEERING TO PROPAGATE (CREATION GUARD)
# =================================================================================
resource "null_resource" "wait_for_vpc_peering" {
  depends_on = [google_service_networking_connection.private_vpc_connection]

  provisioner "local-exec" {
    command = "echo 'Waiting for VPC peering to propagate...' && sleep 120"
  }
}
