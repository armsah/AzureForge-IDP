resource "azurerm_policy_definition" "allowed_locations" {
  name         = "azureforge-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "AzureForge allowed resource locations"
  description  = "Denies AzureForge service resources deployed outside approved Azure regions."

  metadata = jsonencode({
    category = "AzureForge"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "Azure regions approved by the AzureForge golden path."
        strongType  = "location"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "azforge-allowed-locations"
  display_name         = "AzureForge allowed resource locations"
  description          = "Blocks resources outside the AzureForge-approved regions."
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  enforce              = true

  parameters = jsonencode({
    allowedLocations = {
      value = sort(tolist(var.allowed_locations))
    }
  })
}

resource "azurerm_policy_definition" "required_tags" {
  for_each = var.required_tags

  name         = "azureforge-require-tag-${each.value}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "AzureForge require tag: ${each.value}"
  description  = "Denies AzureForge service resources that do not contain the mandatory '${each.value}' tag."

  metadata = jsonencode({
    category = "AzureForge"
  })

  policy_rule = jsonencode({
    if = {
      field  = "tags['${each.value}']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "required_tags" {
  for_each = var.required_tags

  name                 = "azforge-tag-${each.value}"
  display_name         = "AzureForge require tag: ${each.value}"
  description          = "Blocks resources missing the mandatory AzureForge '${each.value}' tag."
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.required_tags[each.value].id
  enforce              = true
}

resource "azurerm_policy_definition" "managed_by_value" {
  name         = "azureforge-managed-by-value"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "AzureForge managed-by tag value"
  description  = "Denies AzureForge service resources whose managed-by tag is not azureforge."

  metadata = jsonencode({
    category = "AzureForge"
  })

  parameters = jsonencode({
    requiredValue = {
      type = "String"
      metadata = {
        displayName = "Required managed-by value"
        description = "Value required for the AzureForge managed-by tag."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "tags['managed-by']"
          exists = "true"
        },
        {
          field     = "tags['managed-by']"
          notEquals = "[parameters('requiredValue')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "managed_by_value" {
  name                 = "azforge-managed-by-value"
  display_name         = "AzureForge managed-by tag value"
  description          = "Blocks resources whose managed-by tag does not equal azureforge."
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.managed_by_value.id
  enforce              = true

  parameters = jsonencode({
    requiredValue = {
      value = var.managed_by_value
    }
  })
}