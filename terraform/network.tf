resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = format("%s-vnet01", azurerm_resource_group.rg.name)
  resource_group_name = azurerm_resource_group.rg.name
}

# done in azapi as azurerm resource doesnt support the devopsinfrastructure/pools delegation yet
# resource "azapi_resource" "mdp" {
#   type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
#   name      = format("%s-snet01", azurerm_virtual_network.vnet.name)
#   parent_id = azurerm_virtual_network.vnet.id
#   body = {
#     properties = {
#       addressPrefixes = [
#         cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, 0)
#       ]
#       delegations = [
#         {
#           name = "delegation"
#           properties = {
#             serviceName = "Microsoft.DevOpsInfrastructure/pools"
#             # actions = [
#             #   "Microsoft.Network/virtualNetworks/subnets/join/action",
#             #   "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/validate/action",
#             #   "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write"
#             # ]
#           }
#         }
#       ]
#     }
#   }
# }

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
        # "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/validate/action",
        # "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write"
      ]
    }
  }
}

moved {
  from = azurerm_subnet.mdp
  to   = azurerm_subnet.mdp["linux"]
}

resource "azurerm_subnet" "pe" {
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, 1)]
  name                 = format("%s-pe01", azurerm_virtual_network.vnet.name)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
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

moved {
  from = azurerm_subnet_network_security_group_association.mdp-nsg-assoc
  to   = azurerm_subnet_network_security_group_association.mdp-nsg-assoc["linux"]
}

resource "azurerm_subnet_network_security_group_association" "pe-nsg-assoc" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.pe.id
}
