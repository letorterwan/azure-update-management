# Create solution for Update Management

resource "azurerm_log_analytics_solution" "update_management" {
  solution_name         = "Updates"
  location              = module.azure-region.location
  resource_group_name   = module.rg.resource_group_name
  workspace_resource_id = module.run-common.log_analytics_workspace_id
  workspace_name        = module.run-common.log_analytics_workspace_name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# Standard Production Windows Servers Update schedule
resource "azurerm_template_deployment" "update_config_standard_windows-prod" {
  name                = "update-config-standard-windows-prod"
  resource_group_name = module.rg.resource_group_name
  deployment_mode     = "Incremental"
 
  template_body = <<DEPLOY
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
      "apiVersion": "2017-05-15-preview",
      "name": "${module.run-iaas.automation_account_name}/Prod Standard Windows Update Schedule",
      "properties": {
        "updateConfiguration": {
          "operatingSystem": "Windows",
            "windows": {
              "includedUpdateClassifications": "Critical, Security, UpdateRollup, Updates",
              "rebootSetting": "IfRequired"
            },
            "duration": "PT1H",
            "targets": {
              "azureQueries": [
                {
                  "scope": ["${module.rg.resource_group_id}"]
                }
              ]
            }
        },
        "scheduleInfo": {
          "startTime": "2021-01-01T03:00:00+01:00",
          "expiryTime": "9999-12-31T23:59:00+01:00",
          "isEnabled": "true",
          "interval": 1,
          "frequency": "Month",
          "timeZone": "Romance Standard Time",
          "advancedSchedule": {
            "monthlyOccurrences": [
              {
                "occurrence": "4",
                "day": "Wednesday"
              }
            ]
          }
        }
      }
    }
  ]
}
DEPLOY
}