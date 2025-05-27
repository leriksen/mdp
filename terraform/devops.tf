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

resource azuredevops_agent_queue "org_pool_to_mdp" {
  project_id    = azuredevops_project.project.id
  agent_pool_id = data.azuredevops_agent_pool.mdp.id
}

# Grant access to queue to all pipelines in the project
resource "azuredevops_pipeline_authorization" "all_pipelines" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_agent_queue.org_pool_to_mdp.id
  type        = "queue"
}