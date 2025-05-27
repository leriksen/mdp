resource random_uuid "uuid" {}

resource "azapi_resource" "mdp" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
  name      = format("mdp-%s", random_uuid.uuid.result)
  parent_id = azurerm_resource_group.rg.id
  location  = module.globals.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.umi.id
    ]
  }
  body      = {
    properties = {
      devCenterProjectResourceId = azurerm_dev_center_project.mdp.id
      maximumConcurrency         = 2
      organizationProfile        = {
        kind          = "AzureDevOps"
        organizations = [
          {
            url         = "https://dev.azure.com/leiferiksenau"
            parallelism = 1
          }

        ]
        permissionProfile = {
          kind = "Inherit"
        }
      }
      fabricProfile = {
        kind   = "Vmss"
        sku    = {
          name = "Standard_D2ads_v5"
        }
        images = [
          {
            ephemeralType      = "Automatic"
            wellKnownImageName = "ubuntu-24.04"
            buffer             = "*"
          }
        ]
        networkProfile = {
          subnetId = azurerm_subnet.mdp.id
        }
      }
      agentProfile = {
        kind = "Stateless"
      }
    }
  }
}