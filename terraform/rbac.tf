resource "azurerm_role_assignment" "devopsinfrastructure_reader" {
  principal_id         = module.globals.mdp_sp_oid
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "devopsinfrastructure_network_contributor" {
  principal_id         = module.globals.mdp_sp_oid
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
}
