resource "google_compute_instance" "honeypot_server" {
  name         = "cowrie-honeypot-node"
  machine_type = "e2-micro"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    access_config {} # Ephemeral Public IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # 1. Install Docker & Run Cowrie
    apt-get update -y
    apt-get install docker.io -y
    systemctl start docker
    systemctl enable docker
    
    mkdir -p /var/log/cowrie
    chmod 777 /var/log/cowrie
    docker run -p 2222:2222 -v /var/log/cowrie:/cowrie/cowrie-git/var/log/cowrie -d cowrie/cowrie

    # 2. Install Fluent Bit
    curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
    systemctl enable fluent-bit

    # 3. Write Fluent Bit Config File
    cat << 'EOF' > /etc/fluent-bit/fluent-bit.conf
    [SERVICE]
        Flush        5
        Daemon       Off
        Log_Level    info
        Parsers_File parsers.conf

    [INPUT]
        Name         tail
        Path         /var/log/cowrie/cowrie.json
        Parser       json
        Tag          honeypot.gcp

    [OUTPUT]
        Name         s3
        Match        honeypot.*
        Bucket       honeynet-central-logs-2026
        Region       us-east-1
        upload_timeout 1m
    EOF

    # 4. Inject AWS credentials securely into Systemd for cross-cloud access
    mkdir -p /etc/systemd/system/fluent-bit.service.d
    cat << EOF_CREDS > /etc/systemd/system/fluent-bit.service.d/override.conf
    [Service]
    Environment="AWS_ACCESS_KEY_ID=${var.aws_access_key}"
    Environment="AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}"
    EOF_CREDS

    systemctl daemon-reload
    systemctl restart fluent-bit
  EOT
}