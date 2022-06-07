resource "azurerm_resource_group" "wp_client_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}