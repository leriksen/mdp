# resource "azurerm_key_vault" "kv" {
#   location                      = azurerm_resource_group.rg.location
#   name                          = format("%s-akv-%s", lower(azurerm_resource_group.rg.name), lower(var.env))
#   resource_group_name           = azurerm_resource_group.rg.name
#   sku_name                      = module.environment.akv_sku
#   tenant_id                     = data.azurerm_client_config.current.tenant_id
#   public_network_access_enabled = true
#   purge_protection_enabled      = false
#   enable_rbac_authorization     = true
# }
#
# resource "azurerm_private_endpoint" "pe" {
#   location            = azurerm_resource_group.rg.location
#   name                = "akv-pe01"
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.pe.id
#   private_service_connection {
#     is_manual_connection           = false
#     name                           = "psc01"
#     private_connection_resource_id = azurerm_key_vault.kv.id
#     subresource_names              = [
#       "vault"
#     ]
#   }
# }