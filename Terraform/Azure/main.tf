resource "azurerm_resource_group" "rg" { #Create a resource group
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "vnet" { #Create virtual network
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" { #Create subnet
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" { #Create public IP
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" { #Create Network Security Group and rules
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8080"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" { #Create network interface
  name                = var.network_interface_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

#Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" { 
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "tls_private_key" "ssh_key" { #Create storage account for boot diagnostics
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "id_rsa" { #Save Private Key to Directory
  filename = "id_rsa"
  content=tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}

resource "azurerm_linux_virtual_machine" "linuxvm" {  #Create virtual machine
  name                  = var.linux_virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B2ms"
  admin_username        = "ala_klein"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {  #Choose OS Image
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }

    admin_ssh_key { #Add SSH Key to VM
    username   = "ala_klein"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  provisioner "local-exec" { #Prepare file "Redeploy" to receive VM IP
    command = "./dynamicRedeploy.sh"
  }

  provisioner "local-exec" { #Save VM IP to "Redepoy" file
    command = "sed -i 's/{host}/${azurerm_linux_virtual_machine.linuxvm.public_ip_address}/g' ./Redeploy"
  }

  provisioner "local-exec" { #Provision application with Ansible
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ala_klein -i '${azurerm_linux_virtual_machine.linuxvm.public_ip_address},' --private-key ./id_rsa /mnt/c/Users/Klein/Desktop/TCC/Ansible.yml" 
  }
}

