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
