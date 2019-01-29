#!/bin/bash

# parameters
rgName=$1
aksName=$2
namespace=$3
helmReleaseName=$4
appName=$5
canary=$6
varName=$7
buildNum=$8

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

echo "Checking if release $helmReleaseName exists"
installed=$(helm ls | grep $helmReleaseName | wc -l)
if [ "$installed" = "1" ]; then
  echo "Getting release version for $helmReleaseName-$appName-$canary in ns $namespace"
  version=$(kubectl get deploy $helmReleaseName-$appName-$canary -n $namespace -o jsonpath="{.spec.template.spec.containers[?(@.name=='$appName')].image}" | sed 's/.*://')
else
  echo "No install - use current build number"
  version="$buildNum"
fi

if [ "$version" = "" ]; then
  echo "Unable to determine version - default to build num $buildNum"
  version="$buildNum"
fi

echo "$canary version is $version"
echo "##vso[task.setvariable variable=$varName]$version"
