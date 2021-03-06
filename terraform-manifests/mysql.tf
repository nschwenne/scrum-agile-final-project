resource "azurerm_mysql_server" "mysql_server" {
  name                = "mpnsawdsmsqlserver5"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.AMDN_RG.name

  administrator_login          = "dbadmin"
  administrator_login_password = "4567secretPASS"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "8.0"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"

}

resource "azurerm_mysql_database" "wordpress_db" {
  name                = "wordpress_db"
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_virtual_network_rule" "mysql_virtual_network_rule" {
  name                = "mysql-vnet-rule"
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  server_name         = azurerm_mysql_server.mysql_server.name
  subnet_id           = azurerm_subnet.subnet.id
}

output "mysql_server_fqdn" {
  description = "MySQL Server FQDN"
  value       = azurerm_mysql_server.mysql_server.fqdn
}
