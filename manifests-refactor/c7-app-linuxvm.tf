# Update the Server, install nginx and write an index.html

locals {
  webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
#sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd  
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo chmod -R 777 /var/www/html 
sudo echo "IT WORKS!! - VM Hostname: $(hostname)" > /var/www/html/index.html
CUSTOM_DATA  
}

resource "azurerm_linux_virtual_machine" "app-linuxvm" {
  depends_on = [
    azurerm_network_interface.app_linuxvm_nic
  ]
  name                = "app-linuxvm"
  resource_group_name = azurerm_resource_group.wp_client_group.name
  location            = azurerm_resource_group.wp_client_group.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "J0hnth3f1sh3rman"
  network_interface_ids = [
    azurerm_network_interface.app_linuxvm_nic.id
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

  custom_data = base64encode(local.webvm_custom_data)
}


