mock_provider "azurerm" {}
mock_provider "time" {}
mock_provider "kubernetes" {}

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

  aks_namespace_enabled = true
  aks_namespace_name    = "pricing-api"
  aks_kubeconfig_path   = "mock-kubeconfig"

  tags = {
    service     = "pricing-api"
    team        = "commerce-team"
    environment = "dev"
    managed-by  = "azureforge"
    criticality = "medium"
  }
}

run "composes_governed_aks_namespace" {
  command = plan

  assert {
    condition     = module.aks_namespace[0].namespace_name == "pricing-api"
    error_message = "The dev composition must provision the deterministic AzureForge namespace."
  }

  assert {
    condition     = module.aks_namespace[0].resource_quota_name == "azureforge-quota"
    error_message = "The dev composition must attach the standard ResourceQuota."
  }

  assert {
    condition     = module.aks_namespace[0].limit_range_name == "azureforge-default-limits"
    error_message = "The dev composition must attach the standard LimitRange."
  }
}

run "keeps_aks_namespace_optional" {
  command = plan

  variables {
    aks_namespace_enabled = false
    aks_namespace_name    = null
    aks_kubeconfig_path   = null
  }

  assert {
    condition     = length(module.aks_namespace) == 0
    error_message = "The AKS namespace capability must remain optional."
  }
}
