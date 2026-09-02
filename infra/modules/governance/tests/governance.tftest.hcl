mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-pricing-api-dev-weu"
}

run "creates_azureforge_governance_baseline" {
  command = plan

  assert {
    condition     = azurerm_policy_definition.allowed_locations.mode == "Indexed"
    error_message = "The allowed-locations policy must use Indexed mode."
  }

  assert {
    condition = (
      jsondecode(azurerm_policy_definition.allowed_locations.policy_rule).then.effect
      == "deny"
    )
    error_message = "The allowed-locations policy must deny non-compliant resources."
  }

  assert {
    condition = (
      jsondecode(
        azurerm_resource_group_policy_assignment.allowed_locations.parameters
      ).allowedLocations.value
      == ["northeurope", "westeurope"]
    )
    error_message = "The allowed-locations assignment must contain the AzureForge-approved regions."
  }

  assert {
    condition     = azurerm_resource_group_policy_assignment.allowed_locations.enforce
    error_message = "The allowed-locations policy assignment must be enforced."
  }

  assert {
    condition     = length(azurerm_policy_definition.required_tags) == 5
    error_message = "AzureForge must create one mandatory-tag policy definition for each required tag."
  }

  assert {
    condition     = length(azurerm_resource_group_policy_assignment.required_tags) == 5
    error_message = "AzureForge must assign every mandatory-tag policy to the service resource group."
  }

  assert {
    condition = (
      jsondecode(
        azurerm_policy_definition.required_tags["criticality"].policy_rule
      ).then.effect
      == "deny"
    )
    error_message = "The criticality tag policy must deny resources missing the tag."
  }

  assert {
    condition = (
      jsondecode(
        azurerm_policy_definition.required_tags["managed-by"].policy_rule
      ).if.field
      == "tags['managed-by']"
    )
    error_message = "The managed-by mandatory-tag policy must evaluate the managed-by tag."
  }

  assert {
    condition = (
      jsondecode(
        azurerm_policy_definition.managed_by_value.policy_rule
      ).then.effect
      == "deny"
    )
    error_message = "The managed-by value policy must deny resources with an invalid value."
  }

  assert {
    condition = (
      jsondecode(
        azurerm_resource_group_policy_assignment.managed_by_value.parameters
      ).requiredValue.value
      == "azureforge"
    )
    error_message = "The managed-by value assignment must require azureforge."
  }

  assert {
    condition     = output.policy_assignment_count == 7
    error_message = "The AzureForge governance baseline must create seven enforced policy assignments."
  }
}

run "rejects_invalid_resource_group_scope" {
  command = plan

  variables {
    resource_group_id = "rg-pricing-api-dev-weu"
  }

  expect_failures = [
    var.resource_group_id
  ]
}

run "rejects_unapproved_policy_region" {
  command = plan

  variables {
    allowed_locations = [
      "westeurope",
      "eastus"
    ]
  }

  expect_failures = [
    var.allowed_locations
  ]
}

run "rejects_incomplete_required_tag_contract" {
  command = plan

  variables {
    required_tags = [
      "service",
      "team",
      "environment",
      "managed-by"
    ]
  }

  expect_failures = [
    var.required_tags
  ]
}

run "rejects_invalid_managed_by_value" {
  command = plan

  variables {
    managed_by_value = "terraform"
  }

  expect_failures = [
    var.managed_by_value
  ]
}