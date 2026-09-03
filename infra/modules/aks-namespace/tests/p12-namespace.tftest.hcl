mock_provider "kubernetes" {}

variables {
  namespace_name = "pricing-api"

  labels = {
    "azureforge.io/service"     = "pricing-api"
    "azureforge.io/team"        = "commerce-team"
    "azureforge.io/environment" = "dev"
  }
}

run "creates_governed_service_namespace" {
  command = plan

  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].name == "pricing-api"
    error_message = "AzureForge must create the deterministic service namespace."
  }

  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["app.kubernetes.io/managed-by"] == "azureforge"
    error_message = "The namespace must identify AzureForge as its platform manager."
  }

  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["azureforge.io/team"] == "commerce-team"
    error_message = "The namespace must retain the owning team label."
  }

  assert {
    condition     = kubernetes_resource_quota_v1.this.metadata[0].name == "azureforge-quota"
    error_message = "AzureForge must attach the standard namespace ResourceQuota."
  }

  assert {
    condition     = kubernetes_resource_quota_v1.this.spec[0].hard["pods"] == "20"
    error_message = "The standard namespace quota must limit the namespace to 20 pods."
  }

  assert {
    condition     = kubernetes_limit_range_v1.this.metadata[0].name == "azureforge-default-limits"
    error_message = "AzureForge must attach the standard container LimitRange."
  }
}

run "rejects_invalid_namespace_name" {
  command = plan

  variables {
    namespace_name = "Pricing_API"
  }

  expect_failures = [
    var.namespace_name
  ]
}
