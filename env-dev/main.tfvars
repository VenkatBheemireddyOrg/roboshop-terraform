env = "dev"
components = {

  frontend = {
    name      = "frontend"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  mongodb = {
    name      = "mongodb"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  catalogue = {
    name      = "catalogue"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  user = {
    name      = "user"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  cart = {
    name      = "cart"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  mysql = {
    name      = "mysql"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  shipping = {
    name      = "shipping"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  payment = {
    name      = "payment"
    vm_size   = "Standard_DS1_v2"
    container = true
  }

  rabbitmq = {
    name      = "rabbitmq"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  redis = {
    name      = "redis"
    vm_size   = "Standard_DS1_v2"
    container = false
  }
}

