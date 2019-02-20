#!/bin/bash

# variables
rgName=$1
aksName=$2
namespace=$3  # set to monitoring or similar

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

# add repo
echo "Add prometheus operator helm repo"
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/

# install operator
echo "Installing helm prometheus-operator"
helm upgrade --install prometheus-operator coreos/prometheus-operator --namespace $namespace 

# fix kubelet to use http - AKS fix
echo "Fixing kubelet service monitoring to http"
kubectl -n $namespace get servicemonitor kube-prometheus-exporter-kubelets -o yaml | sed 's/https/http/' | kubectl replace -f -

echo "Create custom-dashboards config map"
kubectl create configmap --namespace $namespace custom-dashboards --from-file=custom-dashboards/pu-business-dashboard.json --from-file=custom-dashboards/pu-perf-dashboard.json

# install kube-prometheus
echo "Installing kube-prometheus with custom dashboards"
helm upgrade --install kube-prometheus coreos/kube-prometheus --namespace $namespace --set grafana.serverDashboardConfigmaps[0]=custom-dashboards

