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
variable "ARM-TENANT-ID" {}
variable "ARM-CLIENT-SECRET" {}
variable "ARM-CLIENT-ID" {}
variable "ARM-SUBSCRIPTION-ID" {}