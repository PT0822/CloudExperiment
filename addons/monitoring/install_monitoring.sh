#!/usr/bin/env bash
set -euo pipefail

CHART_PATH="${1:-./kube-prometheus-stack}"
RELEASE="kps"
NS="monitoring"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm not found. Install helm in CloudShell first." >&2
  exit 1
fi

if [ -d "$CHART_PATH" ] || [ -f "$CHART_PATH" ]; then
  helm upgrade --install "$RELEASE" "$CHART_PATH" -n "$NS" --create-namespace -f kube-prometheus-stack-values.yaml
else
  echo "Local chart not found at $CHART_PATH; trying online prometheus-community repo."
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm upgrade --install "$RELEASE" prometheus-community/kube-prometheus-stack -n "$NS" --create-namespace -f kube-prometheus-stack-values.yaml
fi

kubectl rollout status deploy/kps-grafana -n "$NS" --timeout=300s || true
kubectl get pods -n "$NS" -o wide | tee monitoring_pods.txt
kubectl get svc -n "$NS" | tee monitoring_services.txt

echo "Grafana admin user: admin"
echo "Grafana admin password: admin123"
echo "Wait for EXTERNAL-IP of kps-grafana, then open it in browser."
