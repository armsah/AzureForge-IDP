mock_provider "azurerm" {}
mock_provider "time" {}

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

run "composes_monthly_cost_control" {
  command = plan

  assert {
    condition     = module.cost_control.monthly_budget_eur == 80
    error_message = "The dev composition must pass the reviewed monthly budget to cost control."
  }

  assert {
    condition     = module.cost_control.budget_name == "budget-pricing-api-dev"
    error_message = "The dev composition must create the deterministic AzureForge budget name."
  }
}

run "rejects_invalid_environment_ttl" {
  command = plan

  variables {
    environment_ttl_days = 91
  }

  expect_failures = [
    var.environment_ttl_days
  ]
}

run "rejects_invalid_monthly_budget" {
  command = plan

  variables {
    monthly_budget_eur = 0
  }

  expect_failures = [
    var.monthly_budget_eur
  ]
}