#!/bin/bash

# variables
rgName=$1
aksName=$2
serviceName=$3
namespace=$4
dnsName=$5

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName

# get the ip address of the ingress load balancer
echo "Getting LoadBalancer IP address for $serviceName in namespace $namespace"
ip=$(kubectl get svc $serviceName -n $namespace -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")

# find the public IP with that IP address
echo "Getting PIP with IP address $ip"
pip=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[id]" --output tsv)

# update public ip address with DNS name
echo "Setting PIP DNS name to $dnsName"
az network public-ip update --ids $pip --dns-name $dnsName