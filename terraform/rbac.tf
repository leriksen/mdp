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
#
# resource "azurerm_role_assignment" "umi_akv_kvsu" {
#   principal_id         = azurerm_user_assigned_identity.umi.principal_id
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Secrets User"
# }
#
# resource "azurerm_role_assignment" "umi_akv_kvcu" {
#   principal_id         = azurerm_user_assigned_identity.umi.principal_id
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Certificate User"
# }