output "namespace_id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "queue_ids" {
  description = "Resource IDs of the Service Bus queues keyed by queue name."

  value = {
    for name, queue in azurerm_servicebus_queue.this :
    name => queue.id
  }
}

output "queue_names" {
  description = "Names of the provisioned Service Bus queues."
  value       = sort(tolist(var.queue_names))
}
