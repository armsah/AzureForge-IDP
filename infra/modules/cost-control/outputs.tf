output "budget_id" {
  description = "Resource ID of the AzureForge resource-group consumption budget."
  value       = azurerm_consumption_budget_resource_group.this.id
}

output "budget_name" {
  description = "Name of the AzureForge resource-group consumption budget."
  value       = azurerm_consumption_budget_resource_group.this.name
}

output "monthly_budget_eur" {
  description = "Configured monthly Azure cost budget in EUR."
  value       = azurerm_consumption_budget_resource_group.this.amount
}

output "budget_start_date" {
  description = "Stable first-of-month start date used by the Azure consumption budget."
  value       = local.budget_start_date
}