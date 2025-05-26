resource "azurerm_resource_group" "rg" {
  location = module.globals.location
  name     = module.globals.project_name
}