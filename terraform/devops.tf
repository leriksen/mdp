resource "azuredevops_project" "project" {
  name        = lower(module.globals.project_name)
  description = "Managed by Terraform"
  features = {
    repositories = "enabled"
    pipelines    = "enabled"
    boards       = "disabled"
    testplans    = "disabled"
    artifacts    = "disabled"
  }
}

# Grant access to every managed-pool queue to all pipelines, in every project
resource "azuredevops_pipeline_authorization" "all_pipelines" {
  for_each    = data.azuredevops_agent_queue.org_pool_to_mdp
  project_id  = each.value.project_id
  resource_id = each.value.id
  type        = "queue"
}