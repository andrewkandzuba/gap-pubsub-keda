#!/bin/bash

# Exit on error
set -e

echo "Installing Prometheus and Grafana using the kube-prometheus-stack..."

# 1. Add the Prometheus community Helm repository
echo "Adding Prometheus community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 2. Update your Helm repositories
echo "Updating Helm repositories..."
helm repo update

# 3. Create a namespace for monitoring
echo "Creating 'monitoring' namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 4. Install the kube-prometheus-stack Helm chart
echo "Installing kube-prometheus-stack Helm chart into 'monitoring' namespace..."
# This chart includes Prometheus, Grafana, and the Prometheus Adapter for custom metrics.
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring -f prometheus-istio-values.yaml --wait
# 5. DepLoy the Prometheus Adapter separately to ensure it's configured correctly
helm install prometheus-adapter prometheus-community/prometheus-adapter \
      --namespace monitoring \
      --set prometheus.url="http://prometheus-operated.monitoring.svc.cluster.local" \
      --set prometheus.port="9090"

echo ""
echo "Prometheus and Grafana installation complete."
echo "It may take a few minutes for all components to start. You can check the status by running:"
echo "kubectl get pods -n monitoring"
echo ""
echo "To access Grafana, you can port-forward the service:"
echo "kubectl port-forward svc/prometheus-grafana -n monitoring 8080:80"
echo "Then open http://localhost:8080 in your browser."
echo "Default credentials: admin / prom-operator"
echo ""
echo "Once the Prometheus Adapter is running, the 'custom.metrics.k8s.io' API will be available."

