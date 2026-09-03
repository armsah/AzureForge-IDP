mock_provider "azurerm" {}
mock_provider "time" {}

variables {
  resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu"
  budget_name        = "budget-pricing-api-dev"
  monthly_budget_eur = 80
}

run "creates_monthly_resource_group_budget" {
  command = plan

  assert {
    condition     = azurerm_consumption_budget_resource_group.this.amount == 80
    error_message = "The AzureForge monthly budget must use the requested EUR amount."
  }

  assert {
    condition     = azurerm_consumption_budget_resource_group.this.time_grain == "Monthly"
    error_message = "The AzureForge consumption budget must reset monthly."
  }

  assert {
    condition = (
      azurerm_consumption_budget_resource_group.this.resource_group_id
      == var.resource_group_id
    )
    error_message = "The consumption budget must be scoped to the service resource group."
  }

  assert {
    condition     = length(azurerm_consumption_budget_resource_group.this.notification) == 2
    error_message = "The AzureForge budget must contain actual and forecasted cost notifications."
  }

  assert {
    condition = anytrue([
      for notification in azurerm_consumption_budget_resource_group.this.notification :
      notification.threshold == 80 &&
      notification.threshold_type == "Actual"
    ])
    error_message = "The budget must notify when actual cost reaches 80 percent."
  }

  assert {
    condition = anytrue([
      for notification in azurerm_consumption_budget_resource_group.this.notification :
      notification.threshold == 100 &&
      notification.threshold_type == "Forecasted"
    ])
    error_message = "The budget must notify when forecasted cost reaches 100 percent."
  }
}

run "rejects_invalid_resource_group_scope" {
  command = plan

  variables {
    resource_group_id = "rg-pricing-api-dev-weu"
  }

  expect_failures = [
    var.resource_group_id
  ]
}

run "rejects_zero_monthly_budget" {
  command = plan

  variables {
    monthly_budget_eur = 0
  }

  expect_failures = [
    var.monthly_budget_eur
  ]
}

run "rejects_empty_budget_name" {
  command = plan

  variables {
    budget_name = " "
  }

  expect_failures = [
    var.budget_name
  ]
}