terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "vault" {
  address = "http://vault-internal.azdevopsv82.online:8200"
  token   = var.token
}

provider "helm" {
  kubernetes {
  config_path = "~/.kube/config"
  }
}
