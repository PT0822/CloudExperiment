#!/usr/bin/env bash
set -euo pipefail

echo "== docker =="
docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'

echo "== kubectl =="
kubectl version --client=true

echo "== cluster =="
kubectl cluster-info
kubectl get nodes -o wide

echo "== helm =="
helm version

echo "== required env =="
: "${SWR_REGION:=cn-north-4}"
: "${SWR_ORG:?set SWR_ORG first}"
echo "SWR_REGION=${SWR_REGION}"
echo "SWR_ORG=${SWR_ORG}"
