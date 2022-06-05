resource "azurerm_resource_group" "arm_rg" {
  name = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "client_wordpress" {
  name = var.virtual_network_name
  location = var.resource_group_location
  resource_group_name = azurerm_resource_group.arm_rg.name
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "client_subnet" {
  name = "${var.virtual_network_name}_client_subnet"
  resource_group_name = azurerm_resource_group.arm_rg.name
  virtual_network_name = azurerm_virtual_network.client_wordpress.name
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_network_interface" "client_nic" {
  name = "${azurerm_virtual_network.client_wordpress.name}_client_nic"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.client_subnet.id
    private_ip_address_allocation = "Dynamic"
    
  }
}

resource "azurerm_network_security_group" "wp_subnet_nsg" {
  name                = "wp_subnet_nsg"
  location            = azurerm_resource_group.arm_rg.location
  resource_group_name = azurerm_resource_group.arm_rg.name
}


resource "azurerm_subnet_network_security_group_association" "wordpress_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.wordpress_nsg_ingress_rules] # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created - Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354    
  subnet_id                 = azurerm_subnet.client_subnet.id
  network_security_group_id = azurerm_network_security_group.wp_subnet_nsg.id
}

locals {
  web_inbound_ports_map = {
    "100" : "80", 
    "110" : "443",
    "120" : "22",
    "130" : 3306 # MySQL Connection
  } 
}

resource "azurerm_network_security_rule" "wordpress_nsg_ingress_rules" {
  for_each = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.arm_rg.name
  network_security_group_name = azurerm_network_security_group.wp_subnet_nsg.name
}