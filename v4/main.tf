module "network" {
  source = "./modules/network"
  region = "us-central1"
}

module "compute" {
  source = "./modules/compute"

  # Your existing variables...
  network_name = module.network.network_name
  subnet_name  = module.network.subnet_name

  # Pass the AWS credentials down to the startup script
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}