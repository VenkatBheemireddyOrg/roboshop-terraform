### code to create components
# module "components" {
#   for_each = var.components
#   source = "./modules/vm"
#   component = each.value["name"]
#   vm_size = each.value["vm_size"]
#   env = var.env
#   vault_token  = var.token
#   container = each.value["container"]
# }

## code to create aks cluster
module "aks" {
  source = "./modules/aks"

  ###BEG 20250511 added code as part of github-runner workflow
  vault_token = var.token
  ###END 20250511 added code as part of github-runner workflow

  subscription_id = var.subscription_id
  virtual_network_name = "project-setup-network"
}

### code to create databases - mongodb, mysql, rabbitmq, redis
module "databases" {
  for_each = var.databases
  source = "./modules/vm"
  component = each.value["name"]
  vm_size = each.value["vm_size"]
  env = var.env
  vault_token  = var.token
  container = each.value["container"]
}


