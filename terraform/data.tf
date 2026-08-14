data "azurerm_client_config" "current" {}

data "azuredevops_projects" "all" {}

data "azuredevops_agent_queue" "org_pool_to_mdp" {
  for_each   = local.project_pool_queues
  project_id = each.value.project_id
  name       = each.value.pool_name
  # queues only materialize in projects once the managed pools exist;
  # depending on the pool resources defers these reads to apply time
  # whenever a pool has pending changes
  depends_on = [azapi_resource.azdo_mdp]
}