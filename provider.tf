terraform {
  backend "azurerm" {}

  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "3.21.0"
    }
  }
}


# terraform {
#   backend "azurerm" {}
#   required_providers {
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = "2.35.0"
#     }
#
#     grafana = {
#       source = "grafana/grafana"
#       version = "3.21.0"
#     }
#   }
# }

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


### this is required for external-dns step-1
provider "kubernetes" {
  config_path = "~/.kube/config"
}


provider "grafana" {
  url  = "http://grafana-${var.env}.azdevopsv82.online/"
  auth = data.vault_generic_secret.k8s.data["grafana_auth"]
}