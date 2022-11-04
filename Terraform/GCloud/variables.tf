variable "firewall_name" {  default = "web-firewall" }
variable "network_name" {  default = "default" }
variable "vm_name" {  default = "terraform-centos" }
variable "machine_type" {  default = "n2-standard-2" } #n2-standard-2 n2-standard-4
variable "zone" {  default = "southamerica-east1-a" }
variable "vm_image" {  default = "centos-cloud/centos-7" }
variable "cert_name" {  default = "id_rsa" }
