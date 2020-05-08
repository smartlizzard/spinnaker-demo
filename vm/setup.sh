#!/usr/bin/env bash
az provider register -n Microsoft.KeyVault
az keyvault create --name "insightdemo" --resource-group "InsightResourceGroup" --location eastus
az keyvault secret set --name "ARM-SUBSCRIPTION-ID" --vault-name "insightdemo" --value "XXXXXXX-26ff-4d7e-ab7b-1d6831b9c999"
az keyvault secret set --name "ARM-CLIENT-ID" --vault-name "insightdemo" --value "XXXXXXXX-0b5f-4bb5-8cdc-a18c036682c9"
az keyvault secret set --name "ARM-CLIENT-SECRET" --vault-name "insightdemo" --value "XXXXXXXX-79c1-4538-8e92-5ef046114a7e"
az keyvault secret set --name "ARM-TENANT-ID" --vault-name "insightdemo" --value "XXXXXXXX-90b6-4aad-a009-d4481d01445c"
az keyvault secret set --name "STORAGE-ACCOUNT-KEY" --vault-name "insightdemo" --value "XXXXXXXVlBgqRdR8aOibP1ADq135pbiAtoQWkfmNliKfiHZ70jiy+qDmEA6jf8953Zn16krUiNtC6A=="
