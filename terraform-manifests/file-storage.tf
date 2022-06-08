resource "azurerm_storage_account" "storageaccount" {
  name                     = "mpnsdsawstorageaccount5"
  location                 = azurerm_resource_group.AMDN_RG.location
  resource_group_name      = azurerm_resource_group.AMDN_RG.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
