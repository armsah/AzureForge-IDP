locals {
  location_short = {
    westeurope  = "weu"
    northeurope = "neu"
  }

  container_app_environment_name = "cae-${var.service_name}-${var.environment}-${local.location_short[var.location]}"
  container_app_name             = var.service_name

  container_image = "mcr.microsoft.com/k8se/quickstart:latest"
}