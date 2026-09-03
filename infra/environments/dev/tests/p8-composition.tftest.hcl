mock_provider "azurerm" {}

variables {
  service_name                 = "pricing-api"
  team                         = "commerce-team"
  environment                  = "dev"
  location                     = "westeurope"
  resource_group_name          = "rg-pricing-api-dev-weu"
  managed_identity_name        = "id-pricing-api-dev"
  log_analytics_workspace_name = "log-pricing-api-dev-weu"
  application_insights_name    = "appi-pricing-api-dev"
  runtime_language             = "dotnet"
  runtime_version              = "10"
  compute_type                 = "container-apps"
  min_replicas                 = 0
  max_replicas                 = 5
  postgres_enabled             = false
  service_bus_queues           = []
  public_ingress               = false
  workload_identity            = true
  application_insights_enabled = true
  alerts                       = "standard"
  monthly_budget_eur           = 80
  environment_ttl_days         = 30

  tags = {
    service     = "pricing-api"
    team        = "commerce-team"
    environment = "dev"
    managed-by  = "azureforge"
    criticality = "medium"
  }
}

run "composes_standard_observability_by_default" {
  command = plan

  assert {
    condition     = module.observability.workbook_display_name == "pricing-api-dev-observability"
    error_message = "The dev composition must create the deterministic AzureForge observability workbook."
  }

  assert {
    condition     = module.observability.standard_alert_count == 2
    error_message = "The standard alert policy must compose both AzureForge metric alerts."
  }
}

run "keeps_workbook_when_standard_alerts_are_disabled" {
  command = plan

  variables {
    alerts = "none"
  }

  assert {
    condition     = module.observability.workbook_display_name == "pricing-api-dev-observability"
    error_message = "The observability workbook must remain available when standard alerts are disabled."
  }

  assert {
    condition     = module.observability.standard_alert_count == 0
    error_message = "The none alert policy must not compose standard metric alerts."
  }
}

run "rejects_unsupported_alert_policy" {
  command = plan

  variables {
    alerts = "custom"
  }

  expect_failures = [
    var.alerts
  ]
}
