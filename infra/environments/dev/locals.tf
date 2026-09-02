locals {
  location_short = {
    westeurope  = "weu"
    northeurope = "neu"
  }

  container_app_environment_name = "cae-${var.service_name}-${var.environment}-${local.location_short[var.location]}"
  container_app_name             = var.service_name
  container_image                = "mcr.microsoft.com/k8se/quickstart:latest"

  paas_name_suffix = substr(
    md5("${var.team}-${var.service_name}-${var.environment}-${var.location}"),
    0,
    6
  )

  postgres_server_name   = "psql-${var.service_name}-${var.environment}-${local.location_short[var.location]}-${local.paas_name_suffix}"
  postgres_database_name = replace(var.service_name, "-", "_")

  service_bus_namespace_name = "sb-${var.service_name}-${var.environment}-${local.location_short[var.location]}-${local.paas_name_suffix}"
}
