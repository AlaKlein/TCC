data "vsphere_datacenter" "datacenter" {
  name = "dc-01"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#data "vsphere_host" "host" {
#  name          = "192.168.1.5"
#  datacenter_id = data.vsphere_datacenter.datacenter.id
#}

data "vsphere_network" "network" {
  name          = "172.16.11.0"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


## Local OVF/OVA Source
data "vsphere_ovf_vm_template" "ovfLocal" {
  name              = "centos/7"
  disk_provisioning = "thin"
  host_system_id = "fafsa"
  resource_pool_id = "asda"
  datastore_id      = data.vsphere_datastore.datastore.id
  local_ovf_path    = "OVF/centos-7-1-1.x86_64.ovf"
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network.id
  }
}

  #ovf_deploy {
  #  allow_unverified_ssl_cert = false
  #  remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
  #  disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
  #  ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  #}

## Deployment of VM from Local OVF
resource "vsphere_virtual_machine" "vmFromLocalOvf" {
  name                 = "Nested-ESXi-7.0-Terraform-Deploy-2"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  num_cpus             = data.vsphere_ovf_vm_template.ovfLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovfLocal.memory
  guest_id             = data.vsphere_ovf_vm_template.ovfLocal.guest_id
  firmware             = data.vsphere_ovf_vm_template.ovfRemote.firmware
  scsi_type            = data.vsphere_ovf_vm_template.ovfLocal.scsi_type
  nested_hv_enabled    = data.vsphere_ovf_vm_template.ovfLocal.nested_hv_enabled
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = false
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
  }

  vapp {
    properties = {
      "guestinfo.hostname"  = "nested-esxi-02.example.com",
      "guestinfo.ipaddress" = "172.16.11.102",
      "guestinfo.netmask"   = "255.255.255.0",
      "guestinfo.gateway"   = "172.16.11.1",
      "guestinfo.dns"       = "172.16.11.4",
      "guestinfo.domain"    = "example.com",
      "guestinfo.ntp"       = "ntp.example.com",
      "guestinfo.password"  = "VMware1!",
      "guestinfo.ssh"       = "True"
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count,
      disk[2].io_share_count,
      vapp[0].properties,
    ]
  }
}