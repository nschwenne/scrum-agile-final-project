resource "azurerm_public_ip" "public_ip" {
  name                = "publicip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku = "Standard"
}


resource "azurerm_lb" "project_load_balancer" {
  name                = "projectlb"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "load-balancer-publicip"
    public_ip_address_id = azurerm_public_ip.public_ip
  }
}
