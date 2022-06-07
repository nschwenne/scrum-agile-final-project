# Create App Subnet

resource "azurerm_subnet" "app_subnet" {
  name                 = "wp_vnet-app_subnet"
  resource_group_name  = azurerm_resource_group.wp_client_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

# Create App NSG
resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "wp_client_app-nsg"
  location            = azurerm_resource_group.wp_client_group.location
  resource_group_name = azurerm_resource_group.wp_client_group.name

}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nst_associate" {
  depends_on = [
    azurerm_network_security_rule.app_nsg_rule_inbound
  ]
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}

locals {
  inbound_ports_map = {
    "100" : "80"
    "110" : "443"
    "120" : "22"
  }
}

#NSG Inbound Rules
resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
  for_each                    = local.inbound_ports_map
  name                        = "Rule-Port-$(each.value)"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.wp_client_group.name
  network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
}