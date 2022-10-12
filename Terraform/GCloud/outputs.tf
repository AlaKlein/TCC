output "external_ip" {
  value = "${google_compute_instance.centos.network_interface.0.access_config.0.assigned_nat_ip}"
}