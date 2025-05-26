resource "azurerm_dev_center" "mdp" {
  name                = "mdp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dev_center_project" "mdp" {
  dev_center_id       = azurerm_dev_center.mdp.id
  location            = azurerm_resource_group.rg.location
  name                = "mdp"
  resource_group_name = azurerm_resource_group.rg.name
}