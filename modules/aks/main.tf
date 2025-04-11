resource "azurerm_kubernetes_cluster" "main" {
  name                = "main"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kubernetes_version  = "1.31.2"
  dns_prefix          = "dev"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"

    # The below 3 lines are needed to enable autoscaling
    auto_scaling_enabled = true
    min_count  = 1
    max_count  = 10

    # this line is required to create aks cluster under same project-setup-1 network
    vnet_subnet_id = "/subscriptions/9af0e83a-d3ee-4c3c-a244-3274a3457024/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
  }

  # this block is required to create aks cluster under same project-setup-1 network
  aci_connector_linux {
    subnet_name = "/subscriptions/9af0e83a-d3ee-4c3c-a244-3274a3457024/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
  }

  # this block is required to create aks cluster under same project-setup-1 network
  network_profile {
    network_plugin = "azure"
    service_cidr = "10.100.0.0/24"
    dns_service_ip = "10.100.0.100"
  }

  identity {
    type = "SystemAssigned"
  }

}
