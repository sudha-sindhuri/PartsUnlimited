#!/bin/bash

# variables
rgName=$1
pipName=$2
dnsName=$3
varName=$4

echo "Creating PIP for DNS name $dnsName"
az network public-ip create -g $rgName -n $pipName --dns-name $dnsName --allocation-method Static

# find the public IP with that IP address
echo "Getting the static IP address for PIP $pipName"
pip=$(az network public-ip list --query "[?name=='$pipName'].[ipAddress]" --output tsv)

# update public ip address with DNS name
echo "Creating variable $varName containing PIP $pip"
echo "##vso[task.setvariable variable=$varName]$pip"