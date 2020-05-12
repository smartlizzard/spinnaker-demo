variable "name" {
  default = "GIVE_A_NAME"
}
variable "location" {
  default = "eastus"
}
variable "cluster_name" {
    default = "YOUR_CLUSTER_NAME"  
}
variable "dns_prefix" {
  default = "SOMETHING"
}
variable "node_count" {
  default = "1"
}

variable "ResourceGroup" {
  default = "YOUR_RESOURCE_GROUP"
}

variable "tag" {
  default = "Terraform Demo" 
}
variable "VAULT_NAME" {
  default = "GIVE_VAULT_NAME"
}
variable "storage_account" {
  default = "STORAGE_ACCOUNT_NAME"
}
