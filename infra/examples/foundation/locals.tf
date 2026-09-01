locals {
  location_short = {
    westeurope  = "weu"
    northeurope = "neu"
  }

  tags = {
    service     = var.service_name
    team        = var.team
    environment = var.environment
    managed-by  = "azureforge"
    criticality = var.criticality
  }
}
