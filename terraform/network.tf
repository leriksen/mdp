resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = format("%s-vnet01", azurerm_resource_group.rg.name)
  resource_group_name = azurerm_resource_group.rg.name
}

# One delegated subnet per managed pool — a subnet supports only a single
# Microsoft.DevOpsInfrastructure service association link, so pools cannot share.
resource "azurerm_subnet" "mdp" {
  for_each             = local.pools
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, each.value.subnet_index)]
  name                 = format("%s-%s", azurerm_virtual_network.vnet.name, each.value.subnet_name)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.DevOpsInfrastructure/pools"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = format("%s-nsg01", azurerm_virtual_network.vnet.name)
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "mdp-nsg-assoc" {
  for_each                  = azurerm_subnet.mdp
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = each.value.id
}
