module "globals" {
  source = "./modules/context/globals"
}

module "subscription" {
  source = "./modules/context/subscription"
  subscription = "NP"
}

module "environment" {
  source = "./modules/context/environment"
  environment = "dev"
}
