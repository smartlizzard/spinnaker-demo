provider "azurerm" {
    version = "~>2.0"
    features {}
}

terraform {
  backend "azurerm" {
    storage_account_name  = "STORAGE_ACCOUNT_NAME"  # Replace this with your storage account name
    container_name        = "BOLB_CONTAINER_NAME"   # Replace with your container name
    key                   = "BOLB_CONTAINER_NAME/eastus/vm/demo.tfstate"  # YOU CAN CHANGE THIS
  }
}
data "azurerm_subscription" "primary" {
}

resource "azurerm_virtual_network" "network" {
    name                = "${var.name}"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${var.ResourceGroup}"

    tags = {
        environment = "${var.tag}"
    }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "${var.name}-Subnet"
    resource_group_name  = "${var.ResourceGroup}"
    virtual_network_name = "${azurerm_virtual_network.network.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
    name                         = "${var.name}-publicIP"
    location                     = "${var.location}"
    resource_group_name          = "${var.ResourceGroup}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.tag}"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
    name                = "${var.name}-SecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${var.ResourceGroup}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.tag}"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    name                      = "${var.name}-NIC"
    location                  = "${var.location}"
    resource_group_name       = "${var.ResourceGroup}"

    ip_configuration {
        name                          = "${var.name}-NicConfiguration"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
    }

    tags = {
        environment = "${var.tag}"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = "${azurerm_network_interface.nic.id}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

data "template_file" "cloudconfig" {
  template = "${file("user_data.sh")}"
}

resource "azurerm_role_definition" "admin_vm" {
  name        = "admin-vm-role"
  scope       = "${data.azurerm_subscription.primary.id}"
  description = "This is a custom role created via Terraform"

  permissions {
    actions     = ["*"]
    data_actions = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.primary.id}", 
  ]
}
resource "azurerm_role_assignment" "bastion" {
    scope              = "${data.azurerm_subscription.primary.id}"
    role_definition_id = "${azurerm_role_definition.admin_vm.id}"
    principal_id       = "${azurerm_linux_virtual_machine.bastion.identity[0].principal_id}"

    lifecycle {
        ignore_changes = [
            role_definition_id,
        ]
    }
}

data "azurerm_key_vault" "mySecret" {
  name = "${var.VAULT_NAME}" 
  resource_group_name = "${var.vault_rg}"
}

data "azurerm_key_vault_secret" "example" {
  name         = "${var.vault_vm_public_key}"
  key_vault_id = data.azurerm_key_vault.mySecret.id
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "bastion" {
    name                  = "${var.name}-01"
    location              = "${var.location}"
    resource_group_name   = "${var.ResourceGroup}"
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]
    size                  = "${var.vm_size}"
    custom_data           = "${base64encode(data.template_file.cloudconfig.rendered)}"

    os_disk {
        name              = "${var.name}-OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "bastion"   # Name of computer, we can change
    admin_username = "ubuntu"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "ubuntu"
        public_key     = "${data.azurerm_key_vault_secret.example.value}"
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        environment = "${var.tag}"
    }
}

