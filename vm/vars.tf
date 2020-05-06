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
  default ="InsightResourceGroup"
}

variable "ARM_ACCESS_KEY" {}
variable "ARM_TENANT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_SUBSCRIPTION_ID" {}