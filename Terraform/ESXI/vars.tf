
variable "data_center" {
  default = "ha-datacenter"
}
variable "data_store" {
  default = "datastore1"
}
variable "mgmt_lan" {
  default = "VM Network"
}
variable "net_adapter_type" {
  default = "vmxnet3"
}
variable "guest_id" {
  default = "windows9_64Guest"
}
variable "custom_iso_path" {
  default = "ISO/Bob.Ombs.Modified.Win10PEx64.v4.6.ISO"
}
variable "local_ovf_path" { 
  default = "OVF/centos-7-1-1.x86_64.ovf" 
}
variable "vm_count" {
  default = "1"
}
variable "disk_size" {
  default = "10"
}
variable "num_cpus" {
  default = "2"
}
variable "num_mem" {
  default = "2048"
}
variable "name_new_vm" {
  default = "BOB"
}
