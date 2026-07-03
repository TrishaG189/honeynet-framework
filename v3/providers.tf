terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" 
    }
  }
}

# Default Provider (US East)
provider "aws" {
  region = "us-east-1"
}

# Alias Provider (Europe)
provider "aws" {
  alias  = "eu"
  region = "eu-central-1"
}

# Alias Provider (India)
provider "aws" {
  alias  = "in"
  region = "ap-south-1"
}

# Alias Provider (London)
provider "aws" {
  alias  = "uk"
  region = "eu-west-2"
}