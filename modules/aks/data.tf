data "azurerm_resource_group" "main" {
  name = "project-setup-1"
}

data "azurerm_subscription" "current" {}

data "azurerm_container_registry" "main" {
  name                = "roboshopb82"
  resource_group_name = data.azurerm_resource_group.main.name
}

