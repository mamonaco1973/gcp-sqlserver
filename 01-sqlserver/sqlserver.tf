# =================================================================================
# CLOUD SQL INSTANCE: SQL SERVER STANDARD 2019
# =================================================================================
resource "google_sql_database_instance" "sqlserver" {
  name             = "sqlserver-instance"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = "us-central1"

  settings {
    tier = "db-custom-2-7680" # Adjust as needed (vCPUs / memory)

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.sqlserver_vpc.self_link
    }

    backup_configuration {
      enabled = true
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    # Required for SQL Server licensing
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"
  }

  deletion_protection = false

  depends_on = [null_resource.wait_for_vpc_peering]
}

# =================================================================================
# CLOUD SQL USER: SQL SERVER (uses SQL Authentication only)
# =================================================================================
resource "google_sql_user" "sqlserver_user" {
  name     = "sqladmin"
  instance = google_sql_database_instance.sqlserver.name
  host     = "%" # Required for SQL Auth
  password = random_password.sqlserver.result
}

# =================================================================================
# PRIVATE DNS ZONE FOR SQL SERVER
# =================================================================================
resource "google_dns_managed_zone" "private_dns" {
  name       = "internal-sqlserver-zone"
  dns_name   = "internal.sqlserver-zone.local."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.sqlserver_vpc.id
    }
  }

  description = "Private DNS zone for internal SQL Server database"
}

# =================================================================================
# PRIVATE DNS RECORD: sqlserver.internal.sqlserver-zone.local
# =================================================================================
resource "google_dns_record_set" "sqlserver_dns" {
  name         = "sqlserver.internal.sqlserver-zone.local."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private_dns.name

  rrdatas = [google_sql_database_instance.sqlserver.private_ip_address]
}

# =================================================================================
# WAIT FOR VPC PEERING TO PROPAGATE
# =================================================================================
resource "null_resource" "wait_for_vpc_peering" {
  depends_on = [google_service_networking_connection.private_vpc_connection]

  provisioner "local-exec" {
    command = "echo 'NOTE: Waiting for VPC peering to fully propagate...' && sleep 120"
  }
}


