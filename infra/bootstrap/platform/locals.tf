locals {
  tags = {
    service     = "azureforge-platform"
    team        = "platform"
    environment = "bootstrap"
    managed-by  = "azureforge"
    criticality = "high"
  }

  github_subject = "repo:${var.github_owner}@8946419/${var.github_repository}@1349877986:ref:refs/heads/${var.github_branch}"
}
