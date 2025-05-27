data azurerm_client_config "current" {}

# data "azuread_application" "mdp_sp" {
#   display_name = "DevOpsInfrastructure"
# }

data "azuredevops_agent_pool" "mdp" {
  name = azapi_resource.mdp.name
}