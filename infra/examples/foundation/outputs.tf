output "resource_group_name" {
  value = module.resource_group.name
}

output "managed_identity_name" {
  value = module.identity.name
}

output "log_analytics_workspace_name" {
  value = module.monitoring.log_analytics_workspace_name
}

output "application_insights_name" {
  value = module.monitoring.application_insights_name
}
