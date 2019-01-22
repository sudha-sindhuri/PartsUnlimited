#!/bin/bash

# parameters
account=$1
token=$2
pool=$3
replicas=$4
aksName=$5
rgName=$6

# get the k8s cluster creds and write them to a local kubeconfig file
az aks get-credentials -n $aksName -g $rgName
kubectl create ns azdo-agents

git clone https://github.com/Azure/helm-vsts-agent.git ./helm-vsts-agent

helm init --kube-context $aksName
# fix helm RBAC
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

AZDO_TOKEN=$(echo -n $token | base64)
helm install --kube-context $aksName \
  --name azdo-agents \
  --namespace azdo-agents \
  ./helm-vsts-agent/charts/vsts-agent \
  --set vstsToken=$AZDO_TOKEN \
  --set vstsAccount=$account \
  --set vstsPool=$pool \
  --set replicas=$replicas \
  --set resources.limits.cpu=0 \
  --set resources.requests.cpu=0