#!/usr/bin/env bash

export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name ARM-SUBSCRIPTION-ID --vault-name insightdemo --query value -o tsv)
export ARM_CLIENT_ID=$(az keyvault secret show --name ARM-CLIENT-ID --vault-name insightdemo --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name ARM-CLIENT-SECRET --vault-name insightdemo --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --name ARM-TENANT-ID --vault-name insightdemo --query value -o tsv)
export STORAGE_ACCOUNT_KEY=$(az keyvault secret show --name STORAGE-ACCOUNT-KEY --vault-name insightdemo --query value -o tsv)