module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
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