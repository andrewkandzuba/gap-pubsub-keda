#!/bin/bash

# Exit on error
set -e

gcloud container clusters get-credentials dt-sandbox-gke-cluster  --location=us-central1-a

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm status istio-base -n istio-system
helm ls -n istio-system
helm install istiod istio/istiod -n istio-system --wait

kubectl get deployments -n istio-system --output wide
kubectl create namespace istio-ingress

helm install istio-ingress istio/gateway -n istio-ingress --wait
helm status istio-ingress -n istio-ingress