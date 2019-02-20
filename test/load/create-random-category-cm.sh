#!/bin/bash

# variables
rgName=$1
aksName=$2
namespace=$3  # set to load-env or similar

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

# create namespace
nsExists=$(kubectl get namespaces | grep $namespace -w)
if [ "$nsExists" = "" ]; then
    echo "Creating ns $namespace"
    kubectl create ns $namespace
else
    echo "ns $namespace already exists"
fi

# create config map
echo "Create random-category-lua config map"
kubectl create configmap -n $namespace random-category-lua --from-file=random-category.lua
