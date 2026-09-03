output "namespace_name" {
  description = "Provisioned Kubernetes namespace name."
  value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "resource_quota_name" {
  description = "ResourceQuota applied to the namespace."
  value       = kubernetes_resource_quota_v1.this.metadata[0].name
}

output "limit_range_name" {
  description = "LimitRange applied to the namespace."
  value       = kubernetes_limit_range_v1.this.metadata[0].name
}
