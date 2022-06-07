resource "azurerm_virtual_network" "vnet" {
  depends_on = [
    azurerm_resource_group.wp_client_group
  ]
  name                = "wp_client_network"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

