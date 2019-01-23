#!/bin/bash

# parameters
rgName=$1
acrName=$2
aksName=$3
namespace=$4

echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

# get the password to the ACR
echo "Getting password for ACR"
password=$(az acr credential show -n $acrName -g $rgName --query 'passwords[1].value' --output tsv)

nsExists=$(kubectl get namespaces | grep $namespace -w)
if [ "$nsExists" = "" ]; then
    echo "Creating ns $namespace"
    kubectl create ns $namespace
else
    echo "ns $namespace already exists"
fi

secretExists=$(kubectl get secrets -n $namespace | grep $acrName -w)
if [ "$secretExists" = "" ]; then
    echo "Secret $acrName does not exist. Creating..."
    # create the secret in the specified namespace using the ACR name
    kubectl create secret docker-registry $acrName --namespace $namespace \
        --docker-server=https://$acrName.azurecr.io \
        --docker-username=$acrName \
        --docker-password=$password \
        --docker-email=$acrName@10thmagnitude.com
else
    echo "Secret $acrName exists. Skipping..."
fi
