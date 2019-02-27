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
#az aks get-credentials -n $aksName -g $rgName

# get the password value
echo "Get the password for the SQL service"
password=$(kubectl get -n $namespace secret $passwordSecretName -o jsonpath="{.data.sapassword}" | base64 --decode)

# create the secret
echo "Creating the connection string secret"
constr="Data Source=$serverName;Initial Catalog=$dbName;User Id=sa;Password=$password"

exists=$(kubectl get secret -n $namespace | grep $secretName -w)
if [ "$exists" = "" ]; then
    echo "Creating connection string secret $secretName"
    kubectl create secret generic $secretName --from-literal=connectionstring="$constr" -n $namespace
else
    echo "Secret $secretName already exists"
    kubectl create secret generic $secretName --from-literal=connectionstring="$constr" -n $namespace --dry-run -o yaml | kubectl replace -f -
fi