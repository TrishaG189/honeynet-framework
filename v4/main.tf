module "network" {
  source = "./modules/network"
  region = "us-central1"
}

module "compute" {
  source      = "./modules/compute"
  zone        = "us-central1-a"
  vpc_name    = module.network.vpc_name
  subnet_name = module.network.subnet_name
}