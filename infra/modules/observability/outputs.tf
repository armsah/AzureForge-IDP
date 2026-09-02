output "workbook_id" {
  description = "Azure Monitor workbook resource ID."
  value       = azurerm_application_insights_workbook.this.id
}

output "workbook_display_name" {
  description = "Azure Monitor workbook display name."
  value       = azurerm_application_insights_workbook.this.display_name
}

output "standard_alert_ids" {
  description = "Azure Monitor metric alert resource IDs created by the standard alert policy."
  value = compact([
    try(azurerm_monitor_metric_alert.http_5xx[0].id, null),
    try(azurerm_monitor_metric_alert.container_restarts[0].id, null)
  ])
}

output "standard_alert_count" {
  description = "Number of AzureForge standard metric alerts composed for the service."
  value = (
    length(azurerm_monitor_metric_alert.http_5xx) +
    length(azurerm_monitor_metric_alert.container_restarts)
  )
}
