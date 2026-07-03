# 1. The VPC
resource "google_compute_network" "honeynet_vpc" {
  name                    = "honeynet-vpc"
  auto_create_subnetworks = false # We want to define our own custom subnet
}

# 2. The Subnet
resource "google_compute_subnetwork" "honeynet_subnet" {
  name          = "honeynet-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.honeynet_vpc.id
}

# 3. The Firewall (Security Group equivalent)
resource "google_compute_firewall" "honeypot_fw" {
  name    = "honeypot-firewall"
  network = google_compute_network.honeynet_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "2222"] # Allow Admin SSH and Hacker SSH
  }
  source_ranges = ["0.0.0.0/0"]
}