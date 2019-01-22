#!/bin/bash

# parameters
account=$1
token=$2
pool=$3
replicas=$4
aksName=$5
rgName=$6

# get the k8s cluster creds and write them to a local kubeconfig file
echo "Getting credentials for cluster $askName"
az aks get-credentials -n $aksName -g $rgName
echo "Creating tiller serviceaccount"
kubectl apply -f ./tiller-rbac.yml

# init helm
echo "Initializing tiller"
helm init --kube-context $aksName --service-account tiller
sleep 20 # wait for the tiller pods to start up

echo "Cloning helm-vsts-agent repo"
git clone https://github.com/Azure/helm-vsts-agent.git ./helm-vsts-agent
AZDO_TOKEN=$(echo -n $token | base64)
echo "Calling helm upgrade to install/upgrade the AzDO agents"
helm upgrade --install --kube-context $aksName \
  --name azdo-agents \
  --namespace azdo-agents \
  ./helm-vsts-agent/charts/vsts-agent \
  --set vstsToken=$AZDO_TOKEN \
  --set vstsAccount=$account \
  --set vstsPool=$pool \
  --set replicas=$replicas \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=2Gi \
  --set resources.requests.cpu=.5 \
  --set resources.requests.memory=1Gi