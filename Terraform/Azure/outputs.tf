output "vm_ip" {
  value = "http://${azurerm_linux_virtual_machine.linuxvm.public_ip_address}:8080/HelpDesk"
}
