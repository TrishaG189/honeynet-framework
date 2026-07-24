# v3/backend.tf
terraform {
  backend "s3" {
    bucket         = "honeynet-gsoc-26-state" # Ensure this bucket name is globally unique
    key            = "aws/honeynet.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "honeynet-state-lock"
    encrypt        = true
  }
}