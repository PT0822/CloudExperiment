#!/usr/bin/env bash
set -euo pipefail

EVIDENCE_DIR="$HOME/course-evidence-final"
mkdir -p "$EVIDENCE_DIR"

log() { echo; echo "========== $* =========="; }

log "0. ??????"
kubectl get nodes -o wide | tee "$EVIDENCE_DIR/00_nodes.txt"
kubectl get pods -o wide | tee "$EVIDENCE_DIR/01_pods_before.txt"
kubectl get svc | tee "$EVIDENCE_DIR/02_services_before.txt"
kubectl get pvc | tee "$EVIDENCE_DIR/03_pvc_before.txt"

log "1. ??? LoadBalancer Service ??"
cat > backend-svc-lb.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: backend-lb-svc
  namespace: default
  annotations:
    kubernetes.io/elb.class: union
    kubernetes.io/elb.autocreate: '{
      "type": "public",
      "bandwidth_name": "bandwidth-backend-course-2023112557",
      "bandwidth_chargemode": "bandwidth",
      "bandwidth_size": 1,
      "bandwidth_sharetype": "PER",
      "eip_type": "5_bgp",
      "name": "elb-backend-course-2023112557"
    }'
    kubernetes.io/elb.enterpriseID: "0"
    kubernetes.io/elb.lb-algorithm: ROUND_ROBIN
spec:
  type: LoadBalancer
  selector:
    app: backend
  ports:
    - name: service0
      port: 80
      protocol: TCP
      targetPort: 5000
YAML
kubectl apply -f backend-svc-lb.yaml
for i in $(seq 1 60); do
  kubectl get svc backend-lb-svc | tee "$EVIDENCE_DIR/04_backend_lb_wait.txt"
  IP=$(kubectl get svc backend-lb-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  if [ -n "$IP" ]; then break; fi
  sleep 10
done
BACKEND_IP=$(kubectl get svc backend-lb-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
echo "BACKEND_IP=$BACKEND_IP" | tee "$EVIDENCE_DIR/05_backend_lb_ip.txt"
if [ -n "$BACKEND_IP" ]; then
  curl -s "http://${BACKEND_IP}/api/ping" | tee "$EVIDENCE_DIR/06_backend_lb_ping.json"
  echo
fi

log "2. Redis SET/GET testkey ?????"
REDIS_POD=$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$REDIS_POD" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" SET testkey hello && redis-cli -a "$REDIS_PASSWORD" GET testkey' | tee "$EVIDENCE_DIR/07_redis_set_get_before.txt"
kubectl delete pod "$REDIS_POD" | tee "$EVIDENCE_DIR/08_redis_delete_pod.txt"
kubectl rollout status deploy/redis --timeout=180s | tee "$EVIDENCE_DIR/09_redis_rollout_after_delete.txt"
NEW_REDIS_POD=$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$NEW_REDIS_POD" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" GET testkey' | tee "$EVIDENCE_DIR/10_redis_get_after_recreate.txt"
kubectl get pvc | tee "$EVIDENCE_DIR/11_pvc_after_redis_recreate.txt"

log "3. ConfigMap Volume ???????"
FRONTEND_POD=$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$FRONTEND_POD" -- cat /etc/nginx/conf.d/default.conf | tee "$EVIDENCE_DIR/12_nginx_conf_before.txt"
# ?????????? 5001????? Volume ?????????????????
kubectl get cm frontend-nginx-conf -o yaml > frontend-nginx-conf-backup.yaml
kubectl get cm frontend-nginx-conf -o jsonpath='{.data.default\.conf}' | sed 's/backend-svc:80/backend-svc:5001/g' > default.conf.tmp
kubectl create cm frontend-nginx-conf --from-file=default.conf=default.conf.tmp -o yaml --dry-run=client | kubectl apply -f -
sleep 20
kubectl exec "$FRONTEND_POD" -- cat /etc/nginx/conf.d/default.conf | tee "$EVIDENCE_DIR/13_nginx_conf_after_change_to_5001.txt"
kubectl apply -f frontend-nginx-conf-backup.yaml
sleep 20
kubectl exec "$FRONTEND_POD" -- cat /etc/nginx/conf.d/default.conf | tee "$EVIDENCE_DIR/14_nginx_conf_restored.txt"

log "4. HPA ???????"
kubectl scale deploy/backend --replicas=1
kubectl rollout status deploy/backend --timeout=180s
kubectl get hpa backend-hpa | tee "$EVIDENCE_DIR/15_hpa_before_load.txt"
kubectl get pods -l app=backend -o wide | tee "$EVIDENCE_DIR/16_backend_pods_before_load.txt"
TARGET_IP="${BACKEND_IP:-}"
if [ -z "$TARGET_IP" ]; then
  TARGET_IP=$(kubectl get svc frontend-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
fi
if command -v ab >/dev/null 2>&1; then
  (ab -n 20000 -c 200 "http://${TARGET_IP}/api/ping" > "$EVIDENCE_DIR/17_ab_output.txt" 2>&1 || true) &
else
  (for i in $(seq 1 3000); do curl -s "http://${TARGET_IP}/api/ping" >/dev/null & done; wait) &
fi
LOAD_PID=$!
for i in $(seq 1 24); do
  echo "--- sample $i ---" | tee -a "$EVIDENCE_DIR/18_hpa_watch_during_load.txt"
  kubectl get hpa backend-hpa | tee -a "$EVIDENCE_DIR/18_hpa_watch_during_load.txt"
  kubectl get pods -l app=backend | tee -a "$EVIDENCE_DIR/18_hpa_watch_during_load.txt"
  sleep 10
done
kill "$LOAD_PID" 2>/dev/null || true
wait "$LOAD_PID" 2>/dev/null || true
kubectl get hpa backend-hpa | tee "$EVIDENCE_DIR/19_hpa_after_load.txt"
kubectl get pods -l app=backend -o wide | tee "$EVIDENCE_DIR/20_backend_pods_after_load.txt"

echo "Waiting 5 minutes for scale down..."
sleep 300
kubectl get hpa backend-hpa | tee "$EVIDENCE_DIR/21_hpa_after_cooldown.txt"
kubectl get pods -l app=backend -o wide | tee "$EVIDENCE_DIR/22_backend_pods_after_cooldown.txt"

log "5. ??????"
kubectl get deploy,po,svc,pvc,cm,secret,hpa,job -o wide | tee "$EVIDENCE_DIR/23_final_status.txt"

echo "Evidence directory: $EVIDENCE_DIR"

