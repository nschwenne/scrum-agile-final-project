resource "azurerm_resource_group" "storageaccount" {
    name                        =   "storageaccount"
    location                    = var.resource_group_name
    resource_group_name         = var.resource_group_location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}