output "us_honeypot_ip" {
  value = module.compute_us.public_ip
}

output "eu_honeypot_ip" {
  value = module.compute_eu.public_ip
}

output "in_honeypot_ip" {
  value = module.compute_in.public_ip
}