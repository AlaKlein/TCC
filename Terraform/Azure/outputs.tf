output "Application_URL" {
  value = "http://${azurerm_linux_virtual_machine.linuxvm.public_ip_address}:8080/HelpDesk"
}
