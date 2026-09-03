resource "time_static" "budget_anchor" {}

locals {
  budget_start_date = formatdate(
    "YYYY-MM-01'T'00:00:00Z",
    time_static.budget_anchor.rfc3339
  )
}

resource "azurerm_consumption_budget_resource_group" "this" {
  name              = var.budget_name
  resource_group_id = var.resource_group_id
  amount            = var.monthly_budget_eur
  time_grain        = "Monthly"

  time_period {
    start_date = local.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"

    contact_roles = [
      "Owner"
    ]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"

    contact_roles = [
      "Owner"
    ]
  }
}