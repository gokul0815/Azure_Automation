output "public_ip" {
  value = azurerm_public_ip.vm_ip.ip_address
}