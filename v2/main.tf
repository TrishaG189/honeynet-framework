provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "compute" {
  source            = "./modules/compute"
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  public_key_path   = "../admin_key.pub"
}