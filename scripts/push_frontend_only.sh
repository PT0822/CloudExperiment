#!/usr/bin/env bash
set -euo pipefail

: "${SWR_REGION:=cn-north-4}"
: "${SWR_ORG:?set SWR_ORG first}"
: "${SWR_USER:?set SWR_USER first}"
: "${SWR_PASSWORD:?set SWR_PASSWORD first}"

REGISTRY="swr.${SWR_REGION}.myhuaweicloud.com"

cd "$(dirname "$0")/../app"

export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

docker compose build --no-cache frontend
echo "${SWR_PASSWORD}" | docker login -u "${SWR_USER}" --password-stdin "${REGISTRY}"
docker tag frontend:v1 "${REGISTRY}/${SWR_ORG}/frontend:v1"
docker push "${REGISTRY}/${SWR_ORG}/frontend:v1"
