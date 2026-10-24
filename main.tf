terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southeastasia"
}

resource "azurerm_resource_group" "hub_spoke" {
  name     = "rg-hub-spoke-lab"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-sea"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "hub_management" {
  name                 = "snet-hub-management"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "spoke_dev" {
  name                = "vnet-spoke-dev"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "spoke_dev_workload" {
  name                 = "snet-spoke-dev-workload"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke_dev.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "spoke_test" {
  name                = "vnet-spoke-test"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name
}

resource "azurerm_subnet" "spoke_test_workload" {
  name                 = "snet-spoke-test-workload"
  resource_group_name  = azurerm_resource_group.hub_spoke.name
  virtual_network_name = azurerm_virtual_network.spoke_test.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_dev" {
  name                      = "peer-hub-to-dev"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_dev.id
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name                      = "peer-dev-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke_dev.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "hub_to_test" {
  name                      = "peer-hub-to-test"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_test.id
}

resource "azurerm_virtual_network_peering" "test_to_hub" {
  name                      = "peer-test-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke_test.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_network_security_group" "dev" {
  name                = "nsg-spoke-dev"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    environment = "dev"
    project     = "azure-hub-spoke-network"
  }
}

resource "azurerm_subnet_network_security_group_association" "dev" {
  subnet_id                 = azurerm_subnet.spoke_dev_workload.id
  network_security_group_id = azurerm_network_security_group.dev.id
}

resource "azurerm_network_security_group" "test" {
  name                = "nsg-spoke-test"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    environment = "test"
    project     = "azure-hub-spoke-network"
  }
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.spoke_test_workload.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_network_security_rule" "dev_deny_ssh_internet" {
  name                        = "Deny-SSH-From-Internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hub_spoke.name
  network_security_group_name = azurerm_network_security_group.dev.name
}

resource "azurerm_network_security_rule" "dev_deny_rdp_internet" {
  name                        = "Deny-RDP-From-Internet"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hub_spoke.name
  network_security_group_name = azurerm_network_security_group.dev.name
}

resource "azurerm_network_security_rule" "test_deny_ssh_internet" {
  name                        = "Deny-SSH-From-Internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hub_spoke.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_network_security_rule" "test_deny_rdp_internet" {
  name                        = "Deny-RDP-From-Internet"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hub_spoke.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_route_table" "dev" {
  name                = "rt-spoke-dev"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    environment = "dev"
    project     = "azure-hub-spoke-network"
  }
}

resource "azurerm_subnet_route_table_association" "dev" {
  subnet_id      = azurerm_subnet.spoke_dev_workload.id
  route_table_id = azurerm_route_table.dev.id
}

resource "azurerm_route_table" "test" {
  name                = "rt-spoke-test"
  location            = azurerm_resource_group.hub_spoke.location
  resource_group_name = azurerm_resource_group.hub_spoke.name

  tags = {
    environment = "test"
    project     = "azure-hub-spoke-network"
  }
}

resource "azurerm_subnet_route_table_association" "test" {
  subnet_id      = azurerm_subnet.spoke_test_workload.id
  route_table_id = azurerm_route_table.test.id
}