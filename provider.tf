terraform {
  backend "azurerm" {}
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
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


### this is required for external-dns step-1
provider "kubernetes" {
    config_path = "~/.kube/config"
}
