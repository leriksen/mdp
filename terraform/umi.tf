resource "azurerm_user_assigned_identity" "umi" {
  location            = module.globals.location
  name                = format("%s-%s", lower(module.globals.project_name), lower(var.env))
  resource_group_name = azurerm_resource_group.rg.name
}