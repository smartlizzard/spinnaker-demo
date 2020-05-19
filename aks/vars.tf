variable "name" {
  default = "GIVE_A_NAME"
  description= "This will used for create ACR and its service principle"
}

variable "location" {
  default = "eastus"
}
variable "cluster_name" {
  default = "YOUR_CLUSTER_NAME"  
  description= "Name of the cluster"
}
variable "dns_prefix" {
  default = "SOMETHING"
}
variable "node_count" {
  default = "1"
  description= "No of k8s cluster node"
}

variable "ResourceGroup" {
  default = "YOUR_RESOURCE_GROUP"
  description= "This Resource group will create"
}

variable "tag" {
  default = "Terraform Demo" 
}
variable "VAULT_NAME" {
  default = "GIVE_VAULT_NAME"
  description= "Name of the vault"
}
variable "storage_account" {
  default = "STORAGE_ACCOUNT_NAME"
  description= "Put storage account where kube_config will store"
}
variable "container_name" {
  default = "CONTAINER_NAME"
  description= "Put container name where kube_config will store"
}
variable "vault_resource_group" {
  default = "VAULT_RESOURCE_GROUP"
  description= "Put your vault resource group name"
}

