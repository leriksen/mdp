resource azurerm_virtual_network "vnet" {
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

resource azurerm_subnet "mdp" {
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, 0)]
  name                 = format("%s-snet01", azurerm_virtual_network.vnet.name)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.DevOpsInfrastructure/pools"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        # "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/validate/action",
        # "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write"
      ]
    }
  }
}

resource azurerm_subnet "pe" {
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 8, 1)]
  name                 = format("%s-pe01", azurerm_virtual_network.vnet.name)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource azurerm_network_security_group "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = format("%s-nsg01", azurerm_virtual_network.vnet.name)
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "mdp-nsg-assoc" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.mdp.id
}

resource "azurerm_subnet_network_security_group_association" "pe-nsg-assoc" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.pe.id
}
