#!/usr/bin/env bash
set -euo pipefail

: "${SWR_REGION:=cn-north-4}"
: "${SWR_ORG:?set SWR_ORG first}"
: "${SWR_USER:?set SWR_USER first}"
: "${SWR_PASSWORD:?set SWR_PASSWORD first}"

REGISTRY="swr.${SWR_REGION}.myhuaweicloud.com"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${REGISTRY}/${SWR_ORG}/pyspark:3.4"

cd "${ROOT}"
docker build -f spark/Dockerfile.spark -t "${IMAGE}" .
echo "${SWR_PASSWORD}" | docker login -u "${SWR_USER}" --password-stdin "${REGISTRY}"
docker push "${IMAGE}"
echo "Pushed ${IMAGE}"
