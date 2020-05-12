# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>2.0"
    features {}
}

terraform {
  backend "azurerm" {
    storage_account_name  = "${var.STORAGE_ACCOUNT_NAME}"
    container_name        = "${var.BOLB_CONTAINER_NAME}"
    key                   = "${var.BOLB_CONTAINER_NAME}/eastus/aks/demo.tfstate"  # YOU CAN CHANGE THIS
  }
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "Resource_Group" {
  name     = "${var.ResourceGroup}"
  location = "${var.location}"

  tags = {
    environment = "${var.tag}"
  }
}

############################## ECR ######################################

provider "azuread" {
  version = "~> 0.3"
}
resource "azurerm_container_registry" "acr" {
  name                = "${var.name}acr768"  # Give unique name
  resource_group_name = "${var.ResourceGroup}"
  location            = "${var.location}"
  sku                 = "standard"
}

resource "azuread_application" "acr-app" {
  name = "${var.name}app768"   # Give unique name
}

resource "azuread_service_principal" "acr-sp" {
  application_id = "${azuread_application.acr-app.application_id}"
}

resource "random_password" "acr_sp_pwd" {
  length  = 16
  special = true
}

resource "azuread_service_principal_password" "acr-sp-pass" {
  service_principal_id = "${azuread_service_principal.acr-sp.id}"
  value                = "${random_password.acr_sp_pwd.result}"
  end_date             = "2021-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "acr-assignment" {
  scope                = "${azurerm_container_registry.acr.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal_password.acr-sp-pass.service_principal_id}"
}

########################## AKS #############################################

resource "azuread_application" "aks_sp" {
  name  = "${var.cluster_name}"
}
resource "azuread_service_principal" "aks_sp" {
  application_id = "${azuread_application.aks_sp.application_id}"
}

resource "random_password" "aks_sp_pwd" {
  length  = 16
  special = true
}

resource "azuread_service_principal_password" "aks_sp_pwd" {
  service_principal_id = "${azuread_service_principal.aks_sp.id}"
  value                = "${random_password.aks_sp_pwd.result}"
  end_date             = "2024-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "aks_sp_role_assignment" {
  scope                = "${data.azurerm_subscription.primary.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.aks_sp.id}"

  depends_on = [
    azuread_service_principal_password.aks_sp_pwd
  ]
}

data "azurerm_key_vault" "mySecret" {
  name = "${var.VAULT_NAME}" 
  resource_group_name = "${var.ResourceGroup}"
}

data "azurerm_key_vault_secret" "example" {
  name         = "VM-PUBLIC-KEY"                 # Give your public key vault secret name
  key_vault_id = data.azurerm_key_vault.mySecret.id
}

resource "azurerm_kubernetes_cluster" "aks" {
    name                = "${var.cluster_name}"
    location            = "${var.location}"
    resource_group_name = "${var.ResourceGroup}"
    dns_prefix          = "${var.dns_prefix}"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
          key_data = "${data.azurerm_key_vault_secret.example.value}"
        }
    }

    default_node_pool {
      name            = "agentpool"
      vm_size         = "Standard_D2s_v3"   # change as per required
      node_count      = "${var.node_count}"
      os_disk_size_gb = 30     # change as per required
    }

    network_profile {
        network_plugin = "kubenet"
        network_policy = "calico"
        load_balancer_sku = "Basic"
    }

    addon_profile {
        http_application_routing {
            enabled = true
        }
    }

    service_principal {
      client_id     = "${azuread_application.aks_sp.application_id}"
      client_secret = "${azuread_service_principal_password.aks_sp_pwd.value}"
    }

    tags = {
      environment = "Terraform Demo"
    }
}
resource "local_file" "kube_config" {
  content     = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  filename    = "kube_config"
}
resource "azurerm_storage_blob" "kube_config" {
  name                   = "config"
  storage_account_name   = "${var.storage_account}"
  storage_container_name = "${var.container_name}"
  type                   = "Block"
  source_content         = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "docker" {
  value = "docker login ${azurerm_container_registry.acr.login_server} -u ${azuread_service_principal.acr-sp.application_id} -p ${azuread_service_principal_password.acr-sp-pass.value}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}