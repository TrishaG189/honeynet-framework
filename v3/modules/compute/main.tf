terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" 
    }
  }
}


resource "aws_key_pair" "admin_key" {
  key_name   = "honeypot-admin-key"
  public_key = file(var.public_key_path)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "honeypot_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.micro"
  key_name             = aws_key_pair.admin_key.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id            = var.subnet_id
  associate_public_ip_address = true
  
  # Inject the secure IAM Profile we created in the previous step
  iam_instance_profile = "aws-honeypot-instance-profile"

  user_data = <<-EOT
    #!/bin/bash
    # 1. Install Docker & Run Cowrie
    apt-get update -y
    apt-get install docker.io -y
    systemctl start docker
    systemctl enable docker
    
    # Run Cowrie and mount its logs directory to the host machine
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
        Tag          honeypot.aws

    [OUTPUT]
        Name         s3
        Match        honeypot.*
        Bucket       honeynet-central-logs-2026
        Region       us-east-1
        
        Upload_Timeout 1m
    EOF

    # 4. Start Log Shipper
    systemctl start fluent-bit
  EOT

  tags = { Name = "Cowrie-Honeypot-Node" }
}