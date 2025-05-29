module "globals" {
  source = "../globals"
}

locals {
  env_sub = {
    dev = "NP"
    prd = "P"
  }
}

module "subscription" {
  source = "../subscription"
  subscription = local.env_sub[var.environment]
}

locals {
  mdp_pool_name = format("%s-%s", module.globals.project_name, var.environment)
  akv_sku = {
    dev = "standard"
    prd = "premium"
  }
}


