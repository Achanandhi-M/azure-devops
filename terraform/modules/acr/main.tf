###############################################################################
# modules/acr/main.tf
# Creates: Azure Container Registry
###############################################################################

resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false # Use managed identity instead of admin credentials

  tags = var.tags
}
