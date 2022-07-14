# Resource group
resource "azurerm_resource_group" "dj_rg" {
  name     = "dj-rg"
  location = "East US 2"
}

# Virtual network
resource "azurerm_virtual_network" "web_network" {
  name                = local.resource_name_tag
  address_space       = [local.vpc_cidr_block]
  location            = azurerm_resource_group.dj_rg.location
  resource_group_name = azurerm_resource_group.dj_rg.name
}

# Subnet
resource "azurerm_subnet" "web_subnet" {
  name                 = local.resource_name_tag
  resource_group_name  = azurerm_resource_group.dj_rg.name
  virtual_network_name = azurerm_virtual_network.web_network.name
  address_prefixes     = [local.subnet_cidr_block]
}

# Public IP
resource "azurerm_public_ip" "web_public_ip" {
  name                = local.resource_name_tag
  location            = azurerm_resource_group.dj_rg.location
  resource_group_name = azurerm_resource_group.dj_rg.name
  allocation_method   = "Static"
  zones           = ["2"]
  sku = "Standard"
}

# Interface
resource "azurerm_network_interface" "web_server_interface" {
  name                = local.resource_name_tag
  location            = azurerm_resource_group.dj_rg.location
  resource_group_name = azurerm_resource_group.dj_rg.name

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_public_ip.id
  }
}

# SG- We will allow all and restrict using ip tables on the VM for Azure. But can restrict here
resource "azurerm_network_security_group" "web_server_sg" {
  name                = local.resource_name_tag
  location            = azurerm_resource_group.dj_rg.location
  resource_group_name = azurerm_resource_group.dj_rg.name

  security_rule {
    name                       = "allow-all-ingress"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-all-egres"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Link sg to the network interface
resource "azurerm_network_interface_security_group_association" "web_server_to_sg" {
  network_interface_id          = azurerm_network_interface.web_server_interface.id
  network_security_group_id     = azurerm_network_security_group.web_server_sg.id
}

# Ubuntu VM- using IPtables for security
resource "azurerm_linux_virtual_machine" "web_server" {
  name                = local.resource_name_tag
  resource_group_name = azurerm_resource_group.dj_rg.name
  location            = azurerm_resource_group.dj_rg.location
  size                = "Standard_B1s"
  zone                = "2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.web_server_interface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("tf_files/publickey.crt")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = filebase64("tf_files/ubuntu_cloud_init.sh")

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
