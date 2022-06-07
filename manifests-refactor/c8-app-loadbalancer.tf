# Create IP for LoadBalancer

resource "azurerm_public_ip" "app_lb_public_ip" {
  name                = "App_LoadBalancer_Public_IP"
  resource_group_name = azurerm_resource_group.wp_client_group.name
  location            = azurerm_resource_group.wp_client_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create the Load Balancer

resource "azurerm_lb" "app_load_balancer" {
  name                = "App-Load-Balancer"
  location            = azurerm_resource_group.wp_client_group.location
  resource_group_name = azurerm_resource_group.wp_client_group.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "app-loadBalancer-public-ip-1"
    public_ip_address_id = azurerm_public_ip.app_lb_public_ip.id
  }
}

# Backend Pool

resource "azurerm_lb_backend_address_pool" "app_lb_backend_pool" {
  name            = "app-backend"
  loadbalancer_id = azurerm_lb.app_load_balancer.id
}

# Load Balancer Probe

resource "azurerm_lb_probe" "app_lb_probe" {
  name            = "app-TCP-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.app_load_balancer.id
}

# LB Rules for ports 80 and 22 (for SSH)

resource "azurerm_lb_rule" "app_lb_rule-80" {
  name                           = "app-lb-rule-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.app_load_balancer.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.app_lb_probe.id
  loadbalancer_id                = azurerm_lb.app_load_balancer.id
}
# resource "azurerm_lb_rule" "app_lb_rule-22" {
#   name = "app-lb-rule-22"
#   protocol = "Tcp"
#   frontend_port = 22
#   backend_port = 22
#   frontend_ip_configuration_name = azurerm_lb.app_load_balancer.frontend_ip_configuration[0].name
#   backend_address_pool_ids = [ azurerm_lb_backend_address_pool.app_lb_backend_pool.id ]
#   probe_id = azurerm_lb_probe.app_lb_probe.id
#   loadbalancer_id = azurerm_lb.app_load_balancer.id
# }

# Associate NIC and LB

resource "azurerm_network_interface_backend_address_pool_association" "app_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.app_linuxvm_nic.id
  ip_configuration_name   = azurerm_network_interface.app_linuxvm_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_lb_backend_pool.id
}

# Load Balancer Inbound NAT

resource "azurerm_lb_nat_rule" "app_lb_inbound_nat_22" {
  name          = "ssh-2222-vm-22"
  protocol      = "Tcp"
  frontend_port = 2222
  backend_port  = 22

  frontend_ip_configuration_name = azurerm_lb.app_load_balancer.frontend_ip_configuration[0].name

  resource_group_name = azurerm_resource_group.wp_client_group.name
  loadbalancer_id     = azurerm_lb.app_load_balancer.id
}

# Associate LB NAT and VM NIC
resource "azurerm_network_interface_nat_rule_association" "app_nic_nat_rule_associate" {
  network_interface_id  = azurerm_network_interface.app_linuxvm_nic.id
  ip_configuration_name = azurerm_network_interface.app_linuxvm_nic.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.app_lb_inbound_nat_22.id

}