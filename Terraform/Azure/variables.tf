variable "resource_group_name" {  default = "my_rg" }

variable "resource_group_location" {  default = "Brazil South"  }

variable "virtual_network_name" { default = "vnet"  }

variable "subnet_name" {  default = "subnet"  }

variable "public_ip_name" { default = "publicip"    }

variable "network_security_group_name" {  default = "nsg" }

variable "network_interface_name" { default = "nic" }

variable "linux_virtual_machine_name" { default = "TerraformCentOS7"  }

variable "machine_size" { default = "Standard_B2ms" }

variable "admin_username" { default = "ala_klein"   }

variable "cert_name" { default = "id_rsa"   }
