resource "azurerm_storage_account" "storageaccount" {
    name                        =   "mpnsdsawstorageaccount"
    location                    = azurerm_resource_group.windows_resource_group.location
    resource_group_name         = azurerm_resource_group.windows_resource_group.name
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}
