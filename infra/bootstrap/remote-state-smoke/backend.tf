terraform {
  required_version = ">= 1.7.0"

  backend "azurerm" {
    use_oidc         = true
    use_azuread_auth = true
  }
}
