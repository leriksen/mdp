resource "azapi_resource" "azdo_mdp" {
  for_each  = local.pools
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
  name      = format("mdp-azdo-%s", each.key)
  parent_id = azurerm_resource_group.rg.id
  location  = module.globals.location
  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.umi.id
  #   ]
  # }
  body = {
    properties = {
      devCenterProjectResourceId = azurerm_dev_center_project.mdp.id
      maximumConcurrency         = each.value.maximumConcurrency
      organizationProfile = {
        kind = "AzureDevOps"
        organizations = [
          {
            url         = module.globals.org_service_url
            parallelism = each.value.parallelism
            openAccess  = true
          }
        ]
        permissionProfile = {
          kind = "Inherit"
        }
      }
      fabricProfile = {
        kind = "Vmss"
        sku = {
          name = each.value.sku
        }
        images = each.value.images
        osProfile = {
          secretsManagementSettings = {
            observedCertificates = []
            keyExportable        = false
          },
          logonType = "Service"
        },
        networkProfile = {
          subnetId = azurerm_subnet.mdp[each.key].id
        }
      }
      agentProfile = {
        kind = "Stateless"
      }
    }
  }
}
#
# resource "azapi_resource" "github_mdp" {
#   type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
#   name      = format("mdp-github")
#   parent_id = azurerm_resource_group.rg.id
#   location  = module.globals.location
#   identity {
#     type = "UserAssigned"
#     identity_ids = [
#       azurerm_user_assigned_identity.umi.id
#     ]
#   }
#   body      = {
#     properties = {
#       devCenterProjectResourceId = azurerm_dev_center_project.mdp.id
#       maximumConcurrency         = 2
#       organizationProfile        = {
#         kind          = "GitHub"
#         organizations = [
#           {
#             url = "https://github.com/leriksen"
#           }
#         ]
#       }
#       fabricProfile = {
#         kind   = "Vmss"
#         sku    = {
#           name = "Standard_D2ads_v5"
#         }
#         images = [
#           {
#             ephemeralType      = "Automatic"
#             wellKnownImageName = "ubuntu-24.04"
#             buffer             = "*"
#           }
#         ]
#         networkProfile = {
#           subnetId = azurerm_subnet.mdp.id
#         }
#       }
#       agentProfile = {
#         kind = "Stateless"
#       }
#     }
#   }
# }