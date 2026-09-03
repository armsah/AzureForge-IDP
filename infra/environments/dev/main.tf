module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "cost_control" {
  source = "../../modules/cost-control"

  resource_group_id  = module.resource_group.id
  budget_name        = "budget-${var.service_name}-${var.environment}"
  monthly_budget_eur = var.monthly_budget_eur
}

module "governance" {
  source = "../../modules/governance"

  resource_group_id = module.resource_group.id

  allowed_locations = [
    "westeurope",
    "northeurope"
  ]

  required_tags = [
    "service",
    "team",
    "environment",
    "managed-by",
    "criticality"
  ]

  managed_by_value = "azureforge"
}

module "identity" {
  source = "../../modules/identity"

  name                = var.managed_identity_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  log_analytics_workspace_name = var.log_analytics_workspace_name
  application_insights_name    = var.application_insights_name
  log_retention_days           = 30
  tags                         = var.tags
}

module "container_app" {
  source = "../../modules/container-app"

  environment_name           = local.container_app_environment_name
  container_app_name         = local.container_app_name
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  managed_identity_id        = module.identity.id

  image          = local.container_image
  target_port    = 80
  public_ingress = var.public_ingress
  min_replicas   = var.min_replicas
  max_replicas   = var.max_replicas

  tags = var.tags
}

module "observability" {
  source = "../../modules/observability"

  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  container_app_id           = module.container_app.container_app_id
  container_app_name         = module.container_app.container_app_name
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  alert_policy               = var.alerts
  workbook_name              = "${var.service_name}-${var.environment}-observability"

  tags = var.tags
}

module "postgres" {
  count  = var.postgres_enabled ? 1 : 0
  source = "../../modules/postgres"

  server_name         = local.postgres_server_name
  database_name       = local.postgres_database_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  postgres_version       = "16"
  administrator_login    = "azureforgeadmin"
  administrator_password = var.postgres_administrator_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  backup_retention_days  = 7

  public_network_access_enabled = false

  tags = var.tags
}

module "service_bus" {
  count  = length(var.service_bus_queues) > 0 ? 1 : 0
  source = "../../modules/service-bus"

  namespace_name      = local.service_bus_namespace_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  queue_names         = toset(var.service_bus_queues)

  tags = var.tags
}
