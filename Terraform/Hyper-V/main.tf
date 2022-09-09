terraform {
  required_providers {
    hyperv = {
      #version = "1.0.3"
      source  = "registry.terraform.io/taliesins/hyperv"
    }
  }
}

#resource "hyperv_network_switch" "dmz_network_switch" {
 #name = "dmz"
#}

#resource "hyperv_network_switch" "default" {
 #name = "DMZ"
#}

#resource "hyperv_vhd" "web_server_g1_vhd" {
  #path = "c:\\web_server\\web_server_g1.vhdx" #Needs to be absolute path
 # size = 10737418240                          #10GB
#}

 resource "hyperv_machine_instance" "web_server_g1" {
   name                   = "test"
   #path                   = "F:/HV/VM"
   generation             = 1
   processor_count        = 2
   static_memory          = true
   memory_startup_bytes   = 536870912 #512MB
   wait_for_state_timeout = 10
   wait_for_ips_timeout   = 10

   vm_processor {
     expose_virtualization_extensions = true
   }

   network_adaptors {
     name         = "wan"
     switch_name  = "lanl"#hyperv_network_switch.dmz_network_switch.name
     wait_for_ips = false
   }

   hard_disk_drives {
     controller_type     = "Ide"
     path                = "C:/HV/disk.vhd"
     controller_number   = 0
     controller_location = 0
   }

}
