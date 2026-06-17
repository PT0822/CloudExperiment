#!/usr/bin/env bash
set -euo pipefail

BACKEND_IP="${1:-}"
if [ -z "${BACKEND_IP}" ]; then
  BACKEND_IP="$(kubectl get svc backend-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
fi

if [ -z "${BACKEND_IP}" ]; then
  echo "usage: $0 <backend_elb_ip>"
  exit 1
fi

echo "Watch in another terminal:"
echo "kubectl get pods -w"

if command -v ab >/dev/null 2>&1; then
  ab -n 10000 -c 200 "http://${BACKEND_IP}/api/ping"
else
  python3 - <<PY
import concurrent.futures
import urllib.request

url = "http://${BACKEND_IP}/api/ping"

def hit(_):
    with urllib.request.urlopen(url, timeout=5) as r:
        return r.status

with concurrent.futures.ThreadPoolExecutor(max_workers=200) as ex:
    for i, status in enumerate(ex.map(hit, range(10000)), 1):
        if i % 500 == 0:
            print(i, status)
PY
fi
