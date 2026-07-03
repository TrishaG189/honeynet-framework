resource "google_compute_instance" "honeypot_server" {
  name         = "cowrie-honeypot-node"
  machine_type = "e2-micro" # FREE TIER ELIGIBLE IN GCP
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnet_name
    access_config {
      # Leaving this empty automatically assigns an Ephemeral Public IP
    }
  }

  metadata_startup_script = <<-EOF
                            #!/bin/bash
                            apt-get update -y
                            apt-get install docker.io -y
                            systemctl start docker
                            systemctl enable docker
                            docker run -p 2222:2222 -d cowrie/cowrie
                            EOF
}