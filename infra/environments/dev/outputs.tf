output "resource_group_name" {
  description = "Provisioned Azure resource group name."
  value       = module.resource_group.name
}

output "managed_identity_name" {
  description = "Provisioned managed identity name."
  value       = module.identity.name
}

output "log_analytics_workspace_name" {
  description = "Provisioned Log Analytics workspace name."
  value       = module.monitoring.log_analytics_workspace_name
}

output "application_insights_name" {
  description = "Provisioned Application Insights name."
  value       = module.monitoring.application_insights_name
}

output "container_app_environment_name" {
  description = "Provisioned Container Apps environment name."
  value       = module.container_app.environment_name
}

output "container_app_name" {
  description = "Provisioned Container App name."
  value       = module.container_app.container_app_name
}

output "container_app_fqdn" {
  description = "Container App ingress FQDN."
  value       = module.container_app.fqdn
}
output "postgres_server_name" {
  description = "Provisioned PostgreSQL Flexible Server name when the capability is enabled."
  value       = try(module.postgres[0].server_name, null)
}

output "postgres_database_name" {
  description = "Provisioned PostgreSQL application database name when the capability is enabled."
  value       = try(module.postgres[0].database_name, null)
}

output "service_bus_namespace_name" {
  description = "Provisioned Service Bus namespace name when the capability is enabled."
  value       = try(module.service_bus[0].namespace_name, null)
}

output "service_bus_queue_names" {
  description = "Provisioned Service Bus queue names."
  value       = try(module.service_bus[0].queue_names, [])
}

output "observability_workbook_id" {
  description = "Azure Monitor workbook resource ID for the service."
  value       = module.observability.workbook_id
}

output "observability_workbook_display_name" {
  description = "Azure Monitor workbook display name for the service."
  value       = module.observability.workbook_display_name
}

output "standard_alert_ids" {
  description = "Azure Monitor metric alert resource IDs created for the service."
  value       = module.observability.standard_alert_ids
}

output "standard_alert_count" {
  description = "Number of AzureForge standard metric alerts composed for the service."
  value       = module.observability.standard_alert_count
}

output "governance_policy_assignment_count" {
  description = "Number of AzureForge governance policy assignments applied to the service resource group."
  value       = module.governance.policy_assignment_count
}

output "allowed_locations_policy_assignment_id" {
  description = "AzureForge allowed-locations policy assignment resource ID."
  value       = module.governance.allowed_locations_assignment_id
}

output "managed_by_value_policy_assignment_id" {
  description = "AzureForge managed-by value policy assignment resource ID."
  value       = module.governance.managed_by_value_assignment_id
}

output "aks_namespace_name" {
  description = "Provisioned Kubernetes namespace when the shared AKS capability is enabled."
  value       = try(module.aks_namespace[0].namespace_name, null)
}

output "aks_namespace_resource_quota_name" {
  description = "ResourceQuota applied to the AzureForge namespace."
  value       = try(module.aks_namespace[0].resource_quota_name, null)
}

output "aks_namespace_limit_range_name" {
  description = "LimitRange applied to the AzureForge namespace."
  value       = try(module.aks_namespace[0].limit_range_name, null)
}
