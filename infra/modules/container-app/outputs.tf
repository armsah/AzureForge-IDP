output "environment_id" {
  description = "Resource ID of the Azure Container Apps environment."
  value       = azurerm_container_app_environment.this.id
}

output "environment_name" {
  description = "Name of the Azure Container Apps environment."
  value       = azurerm_container_app_environment.this.name
}

output "container_app_id" {
  description = "Resource ID of the Azure Container App."
  value       = azurerm_container_app.this.id
}

output "container_app_name" {
  description = "Name of the Azure Container App."
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Fully qualified domain name of the Azure Container App ingress endpoint."
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "latest_revision_name" {
  description = "Name of the latest Container App revision."
  value       = azurerm_container_app.this.latest_revision_name
}