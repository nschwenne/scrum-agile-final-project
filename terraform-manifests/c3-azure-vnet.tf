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
  location            = azurerm_resource_group.windows_virtual_network.location
  resource_group_name = azurerm_resource_group.windows_virtual_network.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.windows_azurerm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

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

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.windows_resource_group.name
  location            = azurerm_resource_group.windows_resource_group.location
  size                = "Standard_DC2s_v2"
  admin_username      = "adminuser"
  admin_password      = "j0hnth3f1sh3rman"
  network_interface_ids = [
    azurerm_network_interface.example.id,
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
