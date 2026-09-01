mock_provider "azurerm" {}

run "creates_resource_group_with_golden_path_metadata" {
  command = plan

  variables {
    name     = "rg-pricing-api-dev-weu"
    location = "westeurope"
    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_resource_group.this.name == "rg-pricing-api-dev-weu"
    error_message = "The resource group name must match the module input."
  }

  assert {
    condition     = azurerm_resource_group.this.tags["managed-by"] == "azureforge"
    error_message = "AzureForge-managed resource groups must retain the managed-by tag."
  }
}

run "rejects_unapproved_region" {
  command = plan

  variables {
    name     = "rg-pricing-api-dev-eus"
    location = "eastus"
    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.location]
}

run "rejects_missing_mandatory_tags" {
  command = plan

  variables {
    name     = "rg-pricing-api-dev-weu"
    location = "westeurope"
    tags = {
      service    = "pricing-api"
      managed-by = "azureforge"
    }
  }

  expect_failures = [var.tags]
}
