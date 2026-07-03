output "vpc_name" {
  value = google_compute_network.honeynet_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.honeynet_subnet.name
}