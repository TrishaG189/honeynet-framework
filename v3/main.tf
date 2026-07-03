# --- 1. US EAST (N. Virginia) ---
module "network_us" {
  source = "./modules/network"
  az     = "us-east-1a"
}

module "compute_us" {
  source            = "./modules/compute"
  subnet_id         = module.network_us.subnet_id
  security_group_id = module.network_us.security_group_id
  public_key_path   = "../admin_key.pub"
}

# --- 2. EUROPE (Frankfurt) ---
module "network_eu" {
  source    = "./modules/network"
  az        = "eu-central-1a"
  providers = { aws = aws.eu } # Forces this module to use the EU provider
}

module "compute_eu" {
  source            = "./modules/compute"
  subnet_id         = module.network_eu.subnet_id
  security_group_id = module.network_eu.security_group_id
  public_key_path   = "../admin_key.pub"
  providers         = { aws = aws.eu }
}

# --- 3. ASIA PACIFIC (Mumbai) ---
module "network_in" {
  source    = "./modules/network"
  az        = "ap-south-1a"
  providers = { aws = aws.in } # Forces this module to use the IN provider
}

module "compute_in" {
  source            = "./modules/compute"
  subnet_id         = module.network_in.subnet_id
  security_group_id = module.network_in.security_group_id
  public_key_path   = "../admin_key.pub"
  providers         = { aws = aws.in }
}

# --- 4. UK (London) ---
module "network_uk" {
  source    = "./modules/network"
  az        = "eu-west-2a"
  providers = { aws = aws.uk } 
}

module "compute_uk" {
  source            = "./modules/compute"
  subnet_id         = module.network_uk.subnet_id
  security_group_id = module.network_uk.security_group_id
  public_key_path   = "../admin_key.pub"
  providers         = { aws = aws.uk }
}