############################################
# GOOGLE COMPUTE INSTANCE: DESKTOP VM
############################################

# Attached to a predefined VPC and subnet with public access via ephemeral IP
# Includes startup script execution via PowerShell
resource "google_compute_instance" "desktop_vm" {
  name                      = "desktop-vm"    # Human-friendly name for this VM in the GCP console
  machine_type              = "e2-standard-2" # Cost-effective general-purpose machine type (2 vCPUs, 8 GB RAM)
  zone                      = "us-central1-a" # Deployment zone—must match the subnet’s region
  allow_stopping_for_update = true            # Allows Terraform to stop/start the VM safely during updates instead of recreating it

  ########################################
  # BOOT DISK CONFIGURATION
  ########################################

  boot_disk {
    initialize_params {
      # Reference the latest Windows Server 2022 image.
      # This is dynamically pulled using the `data` block below.a
      image = data.google_compute_image.windows_2022.self_link
    }
  }

  ########################################
  # NETWORK INTERFACE CONFIGURATION
  ########################################

  # Attach to the defined VPC and subnetwork
  # Enables connectivity to other GCP services and the internet
  network_interface {
    network    = google_compute_network.sqlserver_vpc.id       # Connects to existing VPC (data source must be defined elsewhere)
    subnetwork = google_compute_subnetwork.sqlserver_subnet.id # Ties instance to a specific subnet (CIDR must match deployment logic)
    access_config {}                                           # Creates and attaches a one-time ephemeral public IP (NAT-enabled) for remote desktop or updates
  }

  ########################################
  # STARTUP SCRIPT EXECUTION (WINDOWS)
  ########################################

  # Use metadata to deliver a PowerShell script to the Windows instance at boot time
  # The script is templated with dynamic variables such as the image name
  metadata = {
    windows-startup-script-ps1 = templatefile("./scripts/azurestudio.ps1.template", {
      DBPASSWORD = random_password.vm_generated.result
      DBENDPOINT = "sqlserver.internal.sqlserver-zone.local"
      VMPASSWORD = random_password.vm_generated.result
      VMUSER     = "sysadmin"
    })
  }

  ########################################
  # FIREWALL TAGS
  ########################################

  # Tags used by firewall rules to allow inbound traffic
  # Must match target tags in `google_compute_firewall` rules (e.g., for RDP access)
  tags = ["allow-rdp"] # Enables port 3389 access from the internet (used for Remote Desktop Protocol)
}

############################################
# OUTPUT: PUBLIC IP OF THE DESKTOP VM
############################################

# Outputs the public IP address of the provisioned desktop VM
# Useful for automation, dashboards, or manual access via RDP
output "desktop_public_ip" {
  value       = google_compute_instance.desktop_vm.network_interface[0].access_config[0].nat_ip # Pulls the NAT-assigned public IP
  description = "The public IP address of the Desktop VM."                                      # Friendly label for downstream visibility
}

# ------------------------------------------------------
# DATA SOURCE: Fetch Latest Windows Server 2022 Image
# ------------------------------------------------------
# This data source dynamically fetches the latest Windows Server 2022 image from the official `windows-cloud` project.
# Using a data source ensures your deployment always gets the latest patched image, rather than hard-coding a specific version.
data "google_compute_image" "windows_2022" {
  family  = "windows-2022"  # Official GCP family for Windows Server 2022 images.
  project = "windows-cloud" # This is the GCP project hosting official Microsoft images.
}