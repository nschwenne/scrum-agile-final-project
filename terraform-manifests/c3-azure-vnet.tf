resource "azurerm_resource_group" "windows_resource_group" {
  name     = "windows-rg"
  location = "centralus"
}

resource "azurerm_virtual_network" "windows_virtual_network" {
  name                = "windows-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.windows_resource_group.location
  resource_group_name = azurerm_resource_group.windows_resource_group.name
}

resource "azurerm_subnet" "windows_azurerm_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.windows_resource_group.name
  virtual_network_name = azurerm_virtual_network.windows_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "windows_network_interface" {
  name                = "windows-nic"
  location            = azurerm_resource_group.windows_resource_group.location
  resource_group_name = azurerm_resource_group.windows_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.windows_azurerm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "publicip"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.windows_resource_group.name
  allocation_method   = "Static"
  sku = "Standard"
}


resource "azurerm_lb" "project_load_balancer" {
  name                = "projectlb"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.windows_resource_group.name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "load-balancer-publicip"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  depends_on = [
    azurerm_network_interface.windows_network_interface
  ]
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.windows_resource_group.name
  location            = azurerm_resource_group.windows_resource_group.location
  size                = "Standard_A0"
  admin_username      = "adminuser"
  admin_password      = "j0hnth3f1sh3rman"
  network_interface_ids = [
    azurerm_network_interface.windows_network_interface.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "wp_subnet_nsg" {
  name                = "wp_subnet_nsg"
  location            = azurerm_resource_group.windows_resource_group.location
  resource_group_name = azurerm_resource_group.windows_resource_group.name
}


resource "azurerm_subnet_network_security_group_association" "wordpress_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.wordpress_nsg_ingress_rules]
  subnet_id                 = azurerm_subnet.windows_azurerm_subnet.id
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
  resource_group_name         = azurerm_resource_group.windows_resource_group.name
  network_security_group_name = azurerm_network_security_group.wp_subnet_nsg.name
}
