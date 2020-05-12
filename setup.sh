#!/usr/bin/env bash
az provider register -n Microsoft.KeyVault
az keyvault create --name "GIVE-A-VAULT-MAME" --resource-group "YOUR_RESOURCE_GROUP" --location eastus
az keyvault secret set --name "ARM-SUBSCRIPTION-ID" --vault-name "PUT-VAULT-MAME" --value "XXXXXXX-26ff-4d7e-ab7b-1d6831b9c999"
az keyvault secret set --name "ARM-CLIENT-ID" --vault-name "PUT-VAULT-MAME" --value "XXXXXXXX-0b5f-4bb5-8cdc-a18c036682c9"
az keyvault secret set --name "ARM-CLIENT-SECRET" --vault-name "PUT-VAULT-MAME" --value "XXXXXXXX-79c1-4538-8e92-5ef046114a7e"
az keyvault secret set --name "ARM-TENANT-ID" --vault-name "PUT-VAULT-MAME" --value "XXXXXXXX-90b6-4aad-a009-d4481d01445c"
az keyvault secret set --name "STORAGE-ACCOUNT-KEY" --vault-name "PUT-VAULT-MAME" --value "XXXXXXXVlBgqRdR8aOibP1ADq135pbiAtoQWkfmNliKfiHZ70jiy+qDmEA6jf8953Zn16krUiNtC6A=="
az keyvault secret set --name "VM-PUBLIC-KEY" --vault-name "PUT-VAULT-MAME" --value "YOUR_PUBLIC_KEY"
az keyvault secret set --name "VM-Private-KEY" --vault-name "PUT-VAULT-MAME" --value "YOUR_PRIVATE_KEY"