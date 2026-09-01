output "resource_group_name" {
  value = azurerm_resource_group.bootstrap.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "state_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "github_identity_client_id" {
  value = azurerm_user_assigned_identity.github.client_id
}

output "github_identity_principal_id" {
  value = azurerm_user_assigned_identity.github.principal_id
}

output "github_oidc_subject" {
  value = local.github_subject
}
