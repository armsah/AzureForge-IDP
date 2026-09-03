resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace_name

    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "azureforge"
      },
      var.labels
    )
  }
}

resource "kubernetes_resource_quota_v1" "this" {
  metadata {
    name      = "azureforge-quota"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.quota_cpu_requests
      "requests.memory" = var.quota_memory_requests
      "limits.cpu"      = var.quota_cpu_limits
      "limits.memory"   = var.quota_memory_limits
      "pods"            = tostring(var.quota_pods)
    }
  }
}

resource "kubernetes_limit_range_v1" "this" {
  metadata {
    name      = "azureforge-default-limits"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = var.default_cpu_limit
        memory = var.default_memory_limit
      }

      default_request = {
        cpu    = var.default_cpu_request
        memory = var.default_memory_request
      }
    }
  }
}
