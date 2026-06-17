#!/usr/bin/env bash
set -euo pipefail

: "${SWR_REGION:=cn-north-4}"
: "${SWR_ORG:?set SWR_ORG first}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cp "${ROOT}"/k8s/*.yaml "${TMP_DIR}/"
find "${TMP_DIR}" -type f -name '*.yaml' -print0 | xargs -0 sed -i "s#swr.cn-north-4.myhuaweicloud.com/YOUR_ORG#swr.${SWR_REGION}.myhuaweicloud.com/${SWR_ORG}#g"

kubectl apply -f "${TMP_DIR}/01-configmap-secret.yaml"
kubectl apply -f "${TMP_DIR}/02-pvc.yaml"
kubectl apply -f "${TMP_DIR}/03-redis.yaml"
kubectl apply -f "${TMP_DIR}/04-backend.yaml"
kubectl apply -f "${TMP_DIR}/05-frontend-nginx-configmap.yaml"
kubectl apply -f "${TMP_DIR}/06-frontend.yaml"
kubectl apply -f "${TMP_DIR}/07-services.yaml"
kubectl apply -f "${TMP_DIR}/08-hpa.yaml"

kubectl rollout status deploy/redis --timeout=180s
kubectl rollout status deploy/backend --timeout=180s
kubectl rollout status deploy/frontend --timeout=180s
kubectl get pods,svc,pvc
