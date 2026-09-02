terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.2.0, < 6.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}