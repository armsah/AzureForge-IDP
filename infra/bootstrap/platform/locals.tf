locals {
  tags = {
    service     = "azureforge-platform"
    team        = "platform"
    environment = "bootstrap"
    managed-by  = "azureforge"
    criticality = "high"
  }

  github_subject = "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
}
