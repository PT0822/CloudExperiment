#!/usr/bin/env bash
set -euo pipefail

REDIS_POD="$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')"
echo "current redis pod: ${REDIS_POD}"

kubectl exec "${REDIS_POD}" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" SET testkey hello'
kubectl exec "${REDIS_POD}" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" GET testkey'

kubectl delete pod "${REDIS_POD}"
kubectl rollout status deploy/redis --timeout=180s

NEW_REDIS_POD="$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')"
echo "new redis pod: ${NEW_REDIS_POD}"
kubectl exec "${NEW_REDIS_POD}" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" GET testkey'
