module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-${var.service_name}-${var.environment}-${local.location_short[var.location]}"
  location = var.location
  tags     = local.tags
}

module "identity" {
  source = "../../modules/identity"

  name                = "id-${var.service_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  log_analytics_workspace_name = "log-${var.service_name}-${var.environment}"
  application_insights_name    = "appi-${var.service_name}-${var.environment}"
  log_retention_days           = 30
  tags                         = local.tags
}
