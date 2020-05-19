variable "name" {
  default = "GIVE_A_NAME"
  description= "This will used for create resource with this name"
}
variable "location" {
  default = "eastus"
  description = "Azure region"
}
variable "dns_prefix" {
  default = "demo"
}

variable "tag" {
  default = "Terraform Demo" 
}
variable "vm_size" {
  default = "Standard_B1ms"
  description ="size of vm"
}

variable "vault_name" {
  default = "PUT-VAULT-MAME" # Give your vault name
  description ="Name of the vault"
} 
variable "vault_vm_public_key" {
  default = "VM-PUBLIC-KEY"
  description= "Name of the vault secret in which user public key encrepted with vault"
}
variable "vault_rg" {
  default = "VAULT_RESOURCE_GROUP"
  description= "Put your vault resource group name"
}
