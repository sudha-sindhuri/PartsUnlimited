#!/bin/bash

# variables
rgName=$1
aksName=$2
namespace=$3  # set to load-env or similar
cmName="random-category-lua"

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $aksName"
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
cmExists=$(kubectl get cm -n $namespace | grep $cmName -w)
if [ "$cmExists" = "" ]; then
    echo "Creating cm $cmName"
    kubectl create configmap -n $namespace $cmName --from-file=random-category.lua
else
    echo "Replacing cm $cmName"
    kubectl create configmap -n $namespace $cmName --from-file=random-category.lua --dry-run -o yaml | kubectl replace -f -
fi
