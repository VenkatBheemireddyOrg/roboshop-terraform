### Create public ip address for each component
resource "azurerm_public_ip" "main" {
  name                  = "${var.component}-${var.env}-ip"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  allocation_method     = "Static"
}

### Create network interface for each component
resource "azurerm_network_interface" "main" {
  name                = "${var.component}-${var.env}-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

### Create network interface security group association
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

### Create dns record for each component
resource "azurerm_dns_a_record" "main" {
  name                = "${var.component}-${var.env}"   # I removed "dev" here
  zone_name           = "azdevopsv82.online"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 10
  records             = [azurerm_network_interface.main.private_ip_address]
}

### Create network security group for each component
resource "azurerm_network_security_group" "main" {
  name                = "${var.component}-${var.env}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "main"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

### Create virtual machine for each component
resource "azurerm_virtual_machine" "main" {
  depends_on            = [azurerm_network_interface_security_group_association.main, azurerm_dns_a_record.main]
  name                  = "${var.component}-${var.env}"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B2s"

  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  # This should be your own azure gallery image
  storage_image_reference {
    id = "/subscriptions/9af0e83a-d3ee-4c3c-a244-3274a3457024/resourceGroups/project-setup-1/providers/Microsoft.Compute/galleries/CustomPractice/images/CustomImage"
  }

  # Create disk for each component
  storage_os_disk {
    name              = "${var.component}-${var.env}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.component}-${var.env}"
    admin_username = data.vault_generic_secret.ssh.data["admin_username"]
    admin_password = data.vault_generic_secret.ssh.data["admin_password"]
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

### Running provisioner outside virtual machine code block for each component
### Else it will destroy and re-create the resources when we perform terraform apply
resource "null_resource" "ansible" {

  # This is to hold provisioner until the vm gets created
  depends_on = [azurerm_virtual_machine.main]

  # To run the provisioner on remote machine we are using remote-exec
  provisioner "remote-exec" {

    # To establish connection to remote machine
    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh.data["admin_username"]
      password = data.vault_generic_secret.ssh.data["admin_password"]
      host     = azurerm_public_ip.main.ip_address
    }

    inline = [
      "sudo dnf install python3.12-pip -y",
      "sudo pip3.12 install ansible",
      "ansible-pull -i localhost, -U https://github.com/VenkatBheemireddy/roboshop-ansible.git roboshop.yml -e appl=${var.component}"
      # Commented Raghu Code
      # "ansible-pull -i localhost, -U https://github.com/raghudevopsb82/roboshop-ansible roboshop.yml -e app_name=${var.component} -e ENV=dev"
    ]
  }
}