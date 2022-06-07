resource "azurerm_storage_account" "storageaccount" {
  name                     = "mpnsdsawstorageaccount2"
  location                 = azurerm_resource_group.wp_client_group.location
  resource_group_name      = azurerm_resource_group.wp_client_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
