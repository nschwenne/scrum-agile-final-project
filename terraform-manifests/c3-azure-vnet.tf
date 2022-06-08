resource "azurerm_resource_group" "AMDN_RG" {
  name     = "AMDN_RG"
  location = "centralus"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "publicip"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_lb" "project_load_balancer" {
  name                = "projectlb"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  sku                 = "Basic"
  frontend_ip_configuration {
    name                 = "load-balancer-publicip"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "backend_pool"
  loadbalancer_id = azurerm_lb.project_load_balancer.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.project_load_balancer.id
}

resource "azurerm_lb_nat_rule" "lb-rule" {
  depends_on                     = [azurerm_linux_virtual_machine.VM]
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 2222
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.project_load_balancer.frontend_ip_configuration[0].name
  resource_group_name            = azurerm_resource_group.AMDN_RG.name
  loadbalancer_id                = azurerm_lb.project_load_balancer.id
}

resource "azurerm_network_interface_nat_rule_association" "web_nic_nat_rule_associate" {
  network_interface_id  = azurerm_network_interface.nic.id
  ip_configuration_name = azurerm_network_interface.nic.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.lb-rule.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.AMDN_RG.location
  resource_group_name = azurerm_resource_group.AMDN_RG.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.AMDN_RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.AMDN_RG.location
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  ip_configuration {
    name                          = "vm-ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id = azurerm_public_ip.web_linuxvm_publicip.id 
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = azurerm_network_interface.nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

####################################################################
output "lb_public_ip_address" {
  description = "Load Balancer Public Address"
  value       = azurerm_public_ip.public_ip.ip_address
}
####################################################################
resource "azurerm_linux_virtual_machine" "VM" {
  depends_on = [
    azurerm_network_interface.nic
  ]
  name                = "VM"
  resource_group_name = azurerm_resource_group.AMDN_RG.name
  location            = azurerm_resource_group.AMDN_RG.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "J0hnth3f1sh3rman"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/ssh-keys/key.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "wp_subnet_nsg" {
  name                = "wp_subnet_nsg"
  location            = azurerm_resource_group.AMDN_RG.location
  resource_group_name = azurerm_resource_group.AMDN_RG.name
}

resource "azurerm_network_security_rule" "wordpress_nsg_rules" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.AMDN_RG.name
  network_security_group_name = azurerm_network_security_group.wp_subnet_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "wordpress_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.wordpress_nsg_rules]
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.wp_subnet_nsg.id
}

locals {
  web_inbound_ports_map = {
    "100" : "80",
    "110" : "443",
    "120" : "22",
  }
}