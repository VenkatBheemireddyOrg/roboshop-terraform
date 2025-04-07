data "azurerm_resource_group" "main" {
  name = "project-setup-1"
}

data "azurerm_subnet" "main" {
  name                 = "default"
  virtual_network_name = "project-setup-network"
  resource_group_name  = data.azurerm_resource_group.main.name
}

#data block to retrieve secret from vault
data "vault_generic_secret" "ssh" {
  path = "infra/ssh"
}

