resource "azurerm_servicebus_namespace" "this" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  local_auth_enabled = false

  tags = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queue_names

  name         = each.value
  namespace_id = azurerm_servicebus_namespace.this.id

  max_delivery_count = 10
}