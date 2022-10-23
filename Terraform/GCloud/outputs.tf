output "Application_URL" {
  value = "http://${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip}:8080/HelpDesk"
}