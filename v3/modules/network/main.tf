terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" 
    }
  }
}

resource "aws_vpc" "honeynet_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "Honeynet-Core-VPC" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.honeynet_vpc.id
}

resource "aws_subnet" "honeynet_subnet" {
  vpc_id                  = aws_vpc.honeynet_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az  # <--- THIS MAKES IT DYNAMIC
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.honeynet_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.honeynet_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "honeypot_sg" {
  name        = "honeypot-security-group"
  description = "Allow inbound SSH traffic for hackers and admin"
  vpc_id      = aws_vpc.honeynet_vpc.id

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}