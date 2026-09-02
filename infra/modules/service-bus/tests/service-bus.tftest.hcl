mock_provider "azurerm" {}

run "creates_standard_namespace_and_queues" {
  command = plan

  variables {
    namespace_name     = "sb-pricing-api-dev-weu"
    resource_group_name = "rg-pricing-api-dev-weu"
    location           = "westeurope"
    sku                = "Standard"

    queue_names = [
      "price-update"
    ]

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = azurerm_servicebus_namespace.this.sku == "Standard"
    error_message = "The Service Bus golden path must use the requested Standard SKU."
  }

  assert {
    condition     = length(azurerm_servicebus_queue.this) == 1
    error_message = "The module must create one queue for each requested queue name."
  }

  assert {
    condition     = azurerm_servicebus_queue.this["price-update"].name == "price-update"
    error_message = "The requested Service Bus queue must be provisioned."
  }

    assert {
    condition     = azurerm_servicebus_namespace.this.local_auth_enabled == false
    error_message = "The Service Bus golden path must disable local authentication."
  }
}

run "supports_empty_queue_set" {
  command = plan

  variables {
    namespace_name      = "sb-pricing-api-dev-weu"
    resource_group_name = "rg-pricing-api-dev-weu"
    location            = "westeurope"
    sku                 = "Standard"
    queue_names         = []

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  assert {
    condition     = length(azurerm_servicebus_queue.this) == 0
    error_message = "An empty queue set must not create Service Bus queues."
  }
}

run "rejects_invalid_namespace_name" {
  command = plan

  variables {
    namespace_name      = "bad_name"
    resource_group_name = "rg-pricing-api-dev-weu"
    location            = "westeurope"
    sku                 = "Standard"
    queue_names         = []

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.namespace_name]
}

run "rejects_unsupported_sku" {
  command = plan

  variables {
    namespace_name      = "sb-pricing-api-dev-weu"
    resource_group_name = "rg-pricing-api-dev-weu"
    location            = "westeurope"
    sku                 = "Developer"
    queue_names         = []

    tags = {
      service     = "pricing-api"
      team        = "commerce-team"
      environment = "dev"
      managed-by  = "azureforge"
      criticality = "medium"
    }
  }

  expect_failures = [var.sku]
}