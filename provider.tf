terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = "9af0e83a-d3ee-4c3c-a244-3274a3457024"
}

provider "vault" {
  address = "http://vault-internal.azdevopsv82.online:8200"
  token   = var.token
}

