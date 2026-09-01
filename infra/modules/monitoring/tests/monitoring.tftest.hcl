mock_provider "azurerm" {}

run "creates_standard_monitoring_baseline" {
  command = plan

  variables {
    resource_group_name          = "rg-pricing-api-dev-weu"
    location                     = "westeurope"
    log_analytics_workspace_name = "log-pricing-api-dev"
    application_insights_name    = "appi-pricing-api-dev"
    log_retention_days           = 30
    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.sku == "PerGB2018"
    error_message = "The monitoring baseline must use the approved Log Analytics SKU."
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.retention_in_days == 30
    error_message = "The requested retention period must be applied."
  }

  assert {
    condition     = azurerm_application_insights.this.application_type == "web"
    error_message = "Application Insights must use the web application type."
  }
}

run "rejects_retention_below_baseline" {
  command = plan

  variables {
    resource_group_name          = "rg-pricing-api-dev-weu"
    location                     = "westeurope"
    log_analytics_workspace_name = "log-pricing-api-dev"
    application_insights_name    = "appi-pricing-api-dev"
    log_retention_days           = 7
    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.log_retention_days]
}
