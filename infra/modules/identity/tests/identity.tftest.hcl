mock_provider "azurerm" {}

run "creates_user_assigned_identity" {
  command = plan

  variables {
    name                = "id-pricing-api-dev"
    resource_group_name = "rg-pricing-api-dev-weu"
    location            = "westeurope"
    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_user_assigned_identity.this.name == "id-pricing-api-dev"
    error_message = "The managed identity name must match the module input."
  }

  assert {
    condition     = azurerm_user_assigned_identity.this.resource_group_name == "rg-pricing-api-dev-weu"
    error_message = "The identity must be created in the supplied resource group."
  }
}
