output "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "Fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_id" {
  description = "Resource ID of the PostgreSQL database."
  value       = azurerm_postgresql_flexible_server_database.this.id
}

output "database_name" {
  description = "Name of the PostgreSQL database."
  value       = azurerm_postgresql_flexible_server_database.this.name
}
