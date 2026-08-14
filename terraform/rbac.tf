resource "azurerm_role_assignment" "devopsinfrastructure_reader" {
  principal_id         = azurerm_user_assigned_identity.umi.principal_id
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "devopsinfrastructure_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.umi.principal_id
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
}