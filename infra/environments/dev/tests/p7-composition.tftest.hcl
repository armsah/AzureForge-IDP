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

run "composes_postgres_and_service_bus_when_requested" {
  command = plan

  variables {
    postgres_enabled                = true
    postgres_administrator_password = "Test-Only-P7-Password-123!"

    service_bus_queues = [
      "price-update"
    ]
  }

  assert {
    condition     = length(module.postgres) == 1
    error_message = "PostgreSQL must be composed when postgres_enabled is true."
  }

  assert {
    condition     = length(module.service_bus) == 1
    error_message = "Service Bus must be composed when queues are requested."
  }

  assert {
    condition     = module.postgres[0].database_name == "pricing_api"
    error_message = "PostgreSQL must create the deterministic application database."
  }

  assert {
    condition     = contains(module.service_bus[0].queue_names, "price-update")
    error_message = "Service Bus must contain the requested price-update queue."
  }
}

run "omits_optional_paas_capabilities_when_not_requested" {
  command = plan

  variables {
    postgres_enabled   = false
    service_bus_queues = []
  }

  assert {
    condition     = length(module.postgres) == 0
    error_message = "PostgreSQL must not be composed when postgres_enabled is false."
  }

  assert {
    condition     = length(module.service_bus) == 0
    error_message = "Service Bus must not be composed when no queues are requested."
  }
}

run "supports_service_bus_without_postgres" {
  command = plan

  variables {
    postgres_enabled = false

    service_bus_queues = [
      "price-update",
      "price-audit"
    ]
  }

  assert {
    condition     = length(module.postgres) == 0
    error_message = "PostgreSQL must remain disabled independently of Service Bus."
  }

  assert {
    condition     = length(module.service_bus) == 1
    error_message = "Service Bus must be independently composable."
  }

  assert {
    condition     = length(module.service_bus[0].queue_names) == 2
    error_message = "All requested Service Bus queues must be composed."
  }
}

run "supports_postgres_without_service_bus" {
  command = plan

  variables {
    postgres_enabled                = true
    postgres_administrator_password = "Test-Only-P7-Password-123!"
    service_bus_queues              = []
  }

  assert {
    condition     = length(module.postgres) == 1
    error_message = "PostgreSQL must be independently composable."
  }

  assert {
    condition     = length(module.service_bus) == 0
    error_message = "Service Bus must remain disabled when no queues are requested."
  }
}
