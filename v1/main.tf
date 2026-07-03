# 1. Tell Terraform we are using AWS
provider "aws" {
  region = "us-east-1"
}

# 2. Build a private network lot (VPC)
resource "aws_vpc" "honeynet_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Honeynet-Core-VPC"
  }
  
}

  # 2.5 The Admin Key
resource "aws_key_pair" "admin_key" {
  key_name   = "honeypot-admin-key"
  public_key = file("../admin_key.pub")
}


# 3. The Door to the Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.honeynet_vpc.id
}

# 4. The Specific Plot of Land (Subnet)
resource "aws_subnet" "honeynet_subnet" {
  vpc_id                  = aws_vpc.honeynet_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true # Gives our server a public IP
}

# 5. The Map (Route Table) - Routes internet traffic to the door
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.honeynet_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Link the Map to the Plot of Land
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.honeynet_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. The Security Guard (Firewall)
resource "aws_security_group" "honeypot_sg" {
  name        = "honeypot-security-group"
  description = "Allow inbound SSH traffic for hackers"
  vpc_id      = aws_vpc.honeynet_vpc.id

  # Allow Hackers to enter the honeypot on port 2222
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Admin to SSH into the actual server
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the server to talk to the internet (to download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. Find the latest Free Tier Ubuntu Image automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (The company that makes Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 8. The Fake Bank (EC2 Server + Cowrie Honeypot)
resource "aws_instance" "honeypot_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # FREE TIER ELIGIBLE
  key_name = aws_key_pair.admin_key.key_name
  subnet_id     = aws_subnet.honeynet_subnet.id
  
  vpc_security_group_ids = [aws_security_group.honeypot_sg.id]

  # The Auto-Installer (Runs once when the server boots)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install docker.io -y
              systemctl start docker
              systemctl enable docker
              # Pull and run the Cowrie honeypot image on port 2222
              docker run -p 2222:2222 -d cowrie/cowrie
              EOF

  tags = {
    Name = "Cowrie-Honeypot-Node"
  }
}

# 9. Output the IP address so we know where to attack
output "honeypot_public_ip" {
  value = aws_instance.honeypot_server.public_ip
}