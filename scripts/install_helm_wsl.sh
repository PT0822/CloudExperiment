#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="${ROOT}/helm-v4.2.0-linux-amd64.tar.gz"

if command -v helm >/dev/null 2>&1; then
  helm version
  exit 0
fi

if [ ! -f "${ARCHIVE}" ]; then
  echo "missing ${ARCHIVE}"
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

tar -zxf "${ARCHIVE}" -C "${TMP_DIR}"
mkdir -p "${HOME}/.local/bin"
install "${TMP_DIR}/linux-amd64/helm" "${HOME}/.local/bin/helm"
export PATH="${HOME}/.local/bin:${PATH}"
helm version
