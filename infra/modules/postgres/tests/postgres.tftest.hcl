mock_provider "azurerm" {}

run "creates_postgres_golden_path" {
  command = plan

  variables {
    server_name           = "psql-pricing-api-dev-weu"
    database_name         = "pricing"
    resource_group_name   = "rg-pricing-api-dev-weu"
    location              = "westeurope"
    postgres_version      = "16"
    administrator_login   = "azureforgeadmin"
    administrator_password = "Test-Only-P7-Password-123!"
    sku_name              = "B_Standard_B1ms"
    storage_mb            = 32768
    backup_retention_days = 7

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.this.version == "16"
    error_message = "The PostgreSQL golden path must use the requested PostgreSQL version."
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.this.sku_name == "B_Standard_B1ms"
    error_message = "The PostgreSQL golden path must use the requested compute SKU."
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.this.public_network_access_enabled == false
    error_message = "The PostgreSQL golden path must disable public network access by default."
  }

  assert {
    condition     = azurerm_postgresql_flexible_server_database.this.name == "pricing"
    error_message = "The application database must be created with the requested name."
  }
}

run "rejects_invalid_server_name" {
  command = plan

  variables {
    server_name            = "INVALID_NAME"
    database_name          = "pricing"
    resource_group_name    = "rg-pricing-api-dev-weu"
    location               = "westeurope"
    administrator_password = "Test-Only-P7-Password-123!"

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.server_name]
}

run "rejects_backup_retention_below_baseline" {
  command = plan

  variables {
    server_name            = "psql-pricing-api-dev-weu"
    database_name          = "pricing"
    resource_group_name    = "rg-pricing-api-dev-weu"
    location               = "westeurope"
    administrator_password = "Test-Only-P7-Password-123!"
    backup_retention_days  = 3

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.backup_retention_days]
}

run "rejects_storage_below_golden_path_minimum" {
  command = plan

  variables {
    server_name            = "psql-pricing-api-dev-weu"
    database_name          = "pricing"
    resource_group_name    = "rg-pricing-api-dev-weu"
    location               = "westeurope"
    administrator_password = "Test-Only-P7-Password-123!"
    storage_mb             = 16384

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.storage_mb]
}
