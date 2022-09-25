# Build New VM
data "vsphere_datacenter" "datacenter" {
  name = var.data_center
}
data "vsphere_datastore" "datastore" {
  name          = var.data_store
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_resource_pool" "pool" {}
data "vsphere_network" "networking" {
  name          = var.mgmt_lan
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Data source for the OVF to read the required OVF Properties
data "vsphere_ovf_vm_template" "ovfLocal" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  #host_system_id   = data.vsphere_host.host.id
  local_ovf_path   = var.local_ovf_path
  }

ovf_deploy {
    allow_unverified_ssl_cert = true
    local_ovf_path            = var.local_ovf_path
    disk_provisioning         = "thin"
    deployment_option         = var.deployment_option
 
  }

resource "vsphere_virtual_machine" "virtualmachine" {
  count                      = var.vm_count
  name                       = "${var.name_new_vm}-${count.index + 1}"
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  force_power_off            = true
  shutdown_wait_timeout      = 1
  num_cpus                   = var.num_cpus
  memory                     = var.num_mem
  wait_for_guest_net_timeout = 0
  guest_id                   = var.guest_id
  nested_hv_enabled          = true
  

  network_interface {
    network_id   = data.vsphere_network.networking.id
    adapter_type = var.net_adapter_type
    }
  
  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.custom_iso_path
  }
  disk {
    template = "template"
    size             = var.disk_size
    #label            = "first-disk.vmdk"
    eagerly_scrub    = false
    thin_provisioned = true
  }
  }
  