data "azurerm_resource_group" "main" {
  name = "project-setup-1"
}

data "azurerm_subscription" "current" {}