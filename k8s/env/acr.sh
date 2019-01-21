#!/bin/bash

# variables
rgName=$1
location=$2
acrName=$3

# assumes you're logged in already - if running in AzDO, use Azure CLI task with endpoint

# create resource group
az group create -n $rgName -l $location  --tags owner=colind app=k8spu

# create the ACR enabling admin access
az acr create -n $acrName -g $rgName -l $location --sku Basic --admin-enabled