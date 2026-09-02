mock_provider "azurerm" {}

run "creates_standard_observability_baseline" {
  command = plan

  variables {
    resource_group_name       = "rg-pricing-api-dev-weu"
    location                  = "westeurope"
    container_app_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.App/containerApps/pricing-api"
    container_app_name        = "pricing-api"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.OperationalInsights/workspaces/log-pricing-api-dev-weu"
    alert_policy              = "standard"
    workbook_name             = "pricing-api-dev-observability"

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_application_insights_workbook.this.display_name == "pricing-api-dev-observability"
    error_message = "The observability baseline must create the standard service workbook."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.http_5xx) == 1
    error_message = "The standard alert policy must create the HTTP 5xx alert."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.container_restarts) == 1
    error_message = "The standard alert policy must create the restart alert."
  }

  assert {
    condition     = azurerm_monitor_metric_alert.http_5xx[0].criteria[0].metric_name == "Requests"
    error_message = "The HTTP failure alert must monitor the Requests metric."
  }

  assert {
    condition     = azurerm_monitor_metric_alert.container_restarts[0].criteria[0].metric_name == "RestartCount"
    error_message = "The restart alert must monitor the RestartCount metric."
  }
}

run "supports_observability_without_alerts" {
  command = plan

  variables {
    resource_group_name       = "rg-pricing-api-dev-weu"
    location                  = "westeurope"
    container_app_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.App/containerApps/pricing-api"
    container_app_name        = "pricing-api"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.OperationalInsights/workspaces/log-pricing-api-dev-weu"
    alert_policy              = "none"
    workbook_name             = "pricing-api-dev-observability"

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.http_5xx) == 0
    error_message = "The none alert policy must not create the HTTP 5xx alert."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.container_restarts) == 0
    error_message = "The none alert policy must not create the restart alert."
  }

  assert {
    condition     = azurerm_application_insights_workbook.this.display_name == "pricing-api-dev-observability"
    error_message = "The service workbook must remain available when alerts are disabled."
  }
}

run "rejects_unsupported_alert_policy" {
  command = plan

  variables {
    resource_group_name       = "rg-pricing-api-dev-weu"
    location                  = "westeurope"
    container_app_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.App/containerApps/pricing-api"
    container_app_name        = "pricing-api"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.OperationalInsights/workspaces/log-pricing-api-dev-weu"
    alert_policy              = "custom"
    workbook_name             = "pricing-api-dev-observability"

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.alert_policy]
}

run "rejects_invalid_container_app_id" {
  command = plan

  variables {
    resource_group_name       = "rg-pricing-api-dev-weu"
    location                  = "westeurope"
    container_app_id          = "pricing-api"
    container_app_name        = "pricing-api"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu/providers/Microsoft.OperationalInsights/workspaces/log-pricing-api-dev-weu"
    alert_policy              = "standard"
    workbook_name             = "pricing-api-dev-observability"

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.container_app_id]
}
