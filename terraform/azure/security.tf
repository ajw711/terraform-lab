resource "azurerm_network_security_group" "control" {
  name                = "nsg-control"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_network_security_group" "worker" {
  name                = "nsg-worker"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet_network_security_group_association" "control" {
  subnet_id                 = azurerm_subnet.control.id
  network_security_group_id = azurerm_network_security_group.control.id
}

resource "azurerm_subnet_network_security_group_association" "worker" {
  subnet_id                 = azurerm_subnet.worker.id
  network_security_group_id = azurerm_network_security_group.worker.id
}

resource "azurerm_network_security_rule" "control_ssh" {
  name                       = "allow-ssh-from-bastion"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "10.10.1.0/26"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.control.name
}

resource "azurerm_network_security_rule" "control_k3s_api" {
  name                       = "allow-k3s-api-from-workers"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "6443"
  source_address_prefix      = "10.10.20.0/24"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.control.name
}

resource "azurerm_network_security_rule" "control_vxlan" {
  name                   = "allow-vxlan-from-k3s-nodes"
  priority               = 120
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Udp"
  source_port_range      = "*"
  destination_port_range = "8472"
  source_address_prefixes = [
    "10.10.10.0/24",
    "10.10.20.0/24"
  ]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.control.name
}

resource "azurerm_network_security_rule" "control_kubelet" {
  name                   = "allow-kubelet-from-k3s-nodes"
  priority               = 130
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "10250"
  source_address_prefixes = [
    "10.10.10.0/24",
    "10.10.20.0/24"
  ]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.control.name
}

resource "azurerm_network_security_rule" "worker_ssh" {
  name                       = "allow-ssh-from-bastion"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "10.10.1.0/26"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.worker.name
}

resource "azurerm_network_security_rule" "worker_vxlan" {
  name                   = "allow-vxlan-from-k3s-nodes"
  priority               = 110
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Udp"
  source_port_range      = "*"
  destination_port_range = "8472"
  source_address_prefixes = [
    "10.10.10.0/24",
    "10.10.20.0/24"
  ]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.worker.name
}

resource "azurerm_network_security_rule" "worker_kubelet" {
  name                   = "allow-kubelet-from-k3s-nodes"
  priority               = 120
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "10250"
  source_address_prefixes = [
    "10.10.10.0/24",
    "10.10.20.0/24"
  ]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.worker.name
}