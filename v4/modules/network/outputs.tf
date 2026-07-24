output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.honeynet_vpc.name
}

output "subnet_name" {
  description = "The name of the subnetwork"
  value       = google_compute_subnetwork.honeynet_subnet.name
}