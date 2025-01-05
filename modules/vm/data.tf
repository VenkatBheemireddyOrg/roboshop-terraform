data "azurerm_resource_group" "main" {
  name = "project-setup-1"     ### This is from your azure portal
}

data "azurerm_subnet" "main" {
  name                 = "default"                ### This is from your azure portal
  virtual_network_name = "project-setup-network"  ### This is from your azure portal
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "vault_generic_secret" "ssh" {
  path = "infra/ssh"
}