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

    ### BEG CR24042025 - Code to enable aks "Cluster Autoscaling" or "Node Autoscaling"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 10
    ### END CR24042025 - Code to enable aks "Cluster Autoscaling" or "Node Autoscaling"

    ### BEG CR24042025 - Code to create aks cluster under project-setup-1 network
    vnet_subnet_id = "/subscriptions/9af0e83a-d3ee-4c3c-a244-3274a3457024/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
    ### END CR24042025 - Code to create aks cluster under project-setup-1 network
  }

  ### BEG CR24042025 - Code to create aks cluster under project-setup-1 network
  aci_connector_linux {
    subnet_name = "/subscriptions/9af0e83a-d3ee-4c3c-a244-3274a3457024/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
  }
  network_profile {
    network_plugin = "azure"
    service_cidr = "10.100.0.0/24"
    dns_service_ip = "10.100.0.100"
  }
  ### END CR24042025 - Code to create aks cluster under project-setup-1 network

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks-to-acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

