output "tags" {
  value = merge(
    module.subscription.tags,
    {
      environment = var.environment
    }
  )
}

output "env_sub" {
  value = local.env_sub[var.environment]
}

output "mdp_pool_name" {
  value = local.mdp_pool_name
}

output "akv_sku" {
  value = local.akv_sku[var.environment]
}