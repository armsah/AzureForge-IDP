output "allowed_locations_policy_definition_id" {
  description = "Resource ID of the AzureForge allowed-locations policy definition."
  value       = azurerm_policy_definition.allowed_locations.id
}

output "allowed_locations_assignment_id" {
  description = "Resource ID of the AzureForge allowed-locations resource-group policy assignment."
  value       = azurerm_resource_group_policy_assignment.allowed_locations.id
}

output "required_tag_policy_definition_ids" {
  description = "Resource IDs of the AzureForge mandatory-tag policy definitions."
  value = {
    for tag, policy in azurerm_policy_definition.required_tags :
    tag => policy.id
  }
}

output "required_tag_assignment_ids" {
  description = "Resource IDs of the AzureForge mandatory-tag resource-group policy assignments."
  value = {
    for tag, assignment in azurerm_resource_group_policy_assignment.required_tags :
    tag => assignment.id
  }
}

output "managed_by_value_policy_definition_id" {
  description = "Resource ID of the AzureForge managed-by value policy definition."
  value       = azurerm_policy_definition.managed_by_value.id
}

output "managed_by_value_assignment_id" {
  description = "Resource ID of the AzureForge managed-by value resource-group policy assignment."
  value       = azurerm_resource_group_policy_assignment.managed_by_value.id
}

output "policy_assignment_count" {
  description = "Total number of AzureForge governance policy assignments."
  value       = 2 + length(var.required_tags)
}