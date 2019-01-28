#!/bin/bash

# parameters
rgName=$1
aksName=$2
namespace=$3
helmReleaseName=$4
appName=$5
canary=$6
varName=$7

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

echo "Getting release version for $helmReleaseName-$appName-$canary in $namespace"
version=$(kubectl get deploy $helmReleaseName-$appName-$canary -n $namespace -o jsonpath="{.spec.template.spec.containers[?(@.name=='$appName')].image}" | sed 's/.*://')

echo "Setting variable $varName with value $version"
echo "##vso[task.setvariable variable=$varName]$version"