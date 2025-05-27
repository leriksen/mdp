terraform {
  required_version = "~>1.10.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "2.3.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "3.4.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "1.9.0"
    }
  }

  # cloud {
  #   organization = "leriksen-experiment"
  #   hostname     = "app.terraform.io"
  # }
  backend "local" {
    path = "./terraform.tfstate"
  }
}
