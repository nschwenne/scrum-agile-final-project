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