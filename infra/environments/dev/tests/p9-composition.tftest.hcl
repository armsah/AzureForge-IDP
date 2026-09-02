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

  tags = {
    service     = "pricing-api"
    team        = "commerce-team"
    environment = "dev"
    managed-by  = "azureforge"
    criticality = "medium"
  }
}

run "composes_azureforge_governance_baseline" {
  command = plan

  assert {
    condition     = module.governance.policy_assignment_count == 7
    error_message = "The dev composition must apply all seven AzureForge governance policy assignments."
  }

  assert {
    condition = (
      length(module.governance.required_tag_assignment_ids) == 5
    )
    error_message = "The dev composition must include all five mandatory AzureForge tag assignments."
  }

  assert {
    condition = alltrue([
      for required_tag in [
        "service",
        "team",
        "environment",
        "managed-by",
        "criticality"
      ] :
      contains(keys(module.governance.required_tag_assignment_ids), required_tag)
    ])
    error_message = "The dev composition must preserve the complete AzureForge mandatory-tag contract."
  }
}

run "preserves_existing_golden_path_region_validation" {
  command = plan

  variables {
    location = "eastus"
  }

  expect_failures = [
    var.location
  ]
}