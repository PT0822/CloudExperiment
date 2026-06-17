#!/usr/bin/env bash
set -euo pipefail

echo "== workloads =="
kubectl get deploy,pods,svc,pvc,hpa -o wide

echo "== backend ping =="
BACKEND_IP="$(kubectl get svc backend-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
if [ -z "${BACKEND_IP}" ]; then
  echo "backend LoadBalancer IP is pending"
else
  curl -s "http://${BACKEND_IP}/api/ping"
  echo
fi

echo "== redis persistence quick test =="
REDIS_POD="$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')"
kubectl exec "${REDIS_POD}" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" SET testkey hello'
kubectl exec "${REDIS_POD}" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" GET testkey'

echo "== nginx mounted config =="
FRONTEND_POD="$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')"
kubectl exec "${FRONTEND_POD}" -- cat /etc/nginx/conf.d/default.conf
