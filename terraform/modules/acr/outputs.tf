output "acr_id" {
  description = "Resource ID of the ACR."
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "Name of the ACR."
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "ACR login server FQDN (e.g. myacr.azurecr.io)."
  value       = azurerm_container_registry.main.login_server
}
