variable "name" {
  default = "Insight"
}
variable "location" {
  default = "eastus"
}
variable "cluster_name" {
    default = "demo"  
}
variable "dns_prefix" {
  default = "demo"
}
variable "node_count" {
  default = "1"
}
variable "ResourceGroup" {
  default ="YOUR_RESOURCE_GROUP"
}
variable "STORAGE_ACCOUNT_NAME" {
  default= "YOUR_STORAGE_ACCOUNT_NAME"
}
variable "BOLB_CONTAINER_NAME" {
  default = "YOUR_BOLB_CONTAINER_NAME"
}
variable "tag" {
  default = "Terraform Demo" 
}

variable "VAULT_NAME" {
  default = "PUT-VAULT-MAME" # Give your vault name
}
