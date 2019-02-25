#!/bin/bash

# variables
rgName=$1
aksName=$2
namespace=$3
secretName=$4
serverName=$5
dbName=$6
passwordSecretName=$7

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

# get the password value
$password=$(kubectl get -n $namespace secret $passwordSecretName -o jsonpath="{.data.sapassword}" | base64 --decode)

# create the secret
$constr="Data Source=$serverName;Initial Catalog=$dbName;User Id=sa;Password=$password"
kubectl create secret generic $secretName --from-literal=connectionstring=$constr -n $namespace