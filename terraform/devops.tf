resource "azuredevops_project" "project" {
  name               = lower(module.globals.project_name)
  description        = "Managed by Terraform"
  features = {
    repositories = "enabled"
    pipelines    = "enabled"
    boards       = "disabled"
    testplans    = "disabled"
    artifacts    = "disabled"
  }
}

data "azuredevops_agent_pool" "mdp" {
  name       = azapi_resource.azdo_mdp.name
  depends_on = [azapi_resource.azdo_mdp]
}

data "azuredevops_projects" "all" {
  depends_on = [azuredevops_project.project]
}

data "azuredevops_agent_queue" "org_pool_to_mdp" {
  for_each   = { for p in data.azuredevops_projects.all.projects : p.project_id => p if p.state == "wellFormed" }
  project_id = each.key
  name       = data.azuredevops_agent_pool.mdp.name
}

# Grant access to the mdp-azdo queue to all pipelines, in every project
resource "azuredevops_pipeline_authorization" "all_pipelines" {
  for_each    = data.azuredevops_agent_queue.org_pool_to_mdp
  project_id  = each.key
  resource_id = each.value.id
  type        = "queue"
}