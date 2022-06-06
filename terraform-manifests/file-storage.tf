resource "azurerm_storage_account" "storageaccount" {
    name                        =   "storageaccountname"
    location                    = azurerm_resource_group.windows_resource_group.location
    resource_group_name         = azurerm_resource_group.windows_resource_group.resource_group_name
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}
