mock_provider "azurerm" {}

run "foundation_modules_compose" {
  command = plan

  assert {
    condition     = module.resource_group.name == "rg-pricing-api-dev-weu"
    error_message = "The resource-group module output must be consumable by the composition root."
  }

  assert {
    condition     = module.identity.name == "id-pricing-api-dev"
    error_message = "The identity module must compose with the resource-group module."
  }

  assert {
    condition     = module.monitoring.log_analytics_workspace_name == "log-pricing-api-dev"
    error_message = "The monitoring module must compose with the resource-group module."
  }

  assert {
    condition     = module.monitoring.application_insights_name == "appi-pricing-api-dev"
    error_message = "The monitoring module must expose its Application Insights name."
  }
}
