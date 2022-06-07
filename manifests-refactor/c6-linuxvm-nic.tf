# Create NIC

resource "azurerm_network_interface" "app_linuxvm_nic" {
  name                = "app_linuxvm_nic"
  location            = azurerm_resource_group.wp_client_group.location
  resource_group_name = azurerm_resource_group.wp_client_group.name

  ip_configuration {
    name                          = "app-linuxvm-ip-1"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}