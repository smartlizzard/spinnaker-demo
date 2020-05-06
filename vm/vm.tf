provider "azurerm" {
    version = "~>2.0"
    features {}
    subscription_id = "${var.ARM-SUBSCRIPTION-ID}"
    client_id       = "${var.ARM-CLIENT-ID}"
    client_secret   = "${var.ARM-CLIENT-SECRET}"
    tenant_id       = "${var.ARM-TENANT-ID}"
}

terraform {
  backend "azurerm" {
    storage_account_name  = "insightsinfra"
    container_name        = "terraform"
    key                   = "terraform/eastus/vm/demo.tfstate"
    access_key            = "${var.STORAGE-ACCOUNT-KEY}"
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
        environment = "Terraform Demo"
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
        environment = "Terraform Demo"
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
        environment = "Terraform Demo"
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
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = "${azurerm_network_interface.nic.id}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

# Generate random text for a unique storage account name

# Create virtual machine
resource "azurerm_linux_virtual_machine" "bastion" {
    name                  = "${var.name}-VM"
    location              = "${var.location}"
    resource_group_name   = "${var.ResourceGroup}"
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]
    size                  = "Standard_B1ms"
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

    computer_name  = "bastion"
    admin_username = "ubuntu"
    disable_password_authentication = true
        
    admin_ssh_key {
        username       = "ubuntu"
        public_key     = "${file("./id_rsa.pub")}"
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        environment = "Terraform Demo"
    }
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
