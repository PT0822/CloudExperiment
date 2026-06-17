#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/cloud-course-k8s
cd ~/cloud-course-k8s

cat > 01-configmap-secret.yaml <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: default
data:
  REDIS_HOST: "redis-svc"
  REDIS_PORT: "6379"
  APP_ENV: "production"
---
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
  namespace: default
type: Opaque
data:
  password: cmVkaXMxMjM=
YAML

cat > 02-pvc.yaml <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: csi-disk
  resources:
    requests:
      storage: 10Gi
YAML

cat > 03-redis.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7-alpine
          command: ["sh", "-c"]
          args: ["redis-server --appendonly yes --requirepass \"$REDIS_PASSWORD\""]
          env:
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: redis-secret
                  key: password
          ports:
            - containerPort: 6379
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          volumeMounts:
            - name: redis-data
              mountPath: /data
      volumes:
        - name: redis-data
          persistentVolumeClaim:
            claimName: redis-data-pvc
YAML

cat > 04-backend.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: swr.cn-north-4.myhuaweicloud.com/cloud-course-2023112554/backend:v1
          ports:
            - containerPort: 5000
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          envFrom:
            - configMapRef:
                name: backend-config
          env:
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: redis-secret
                  key: password
          livenessProbe:
            httpGet:
              path: /api/ping
              port: 5000
            initialDelaySeconds: 10
            periodSeconds: 15
YAML

cat > 05-frontend-nginx-configmap.yaml <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-nginx-conf
  namespace: default
data:
  default.conf: |
    server {
        listen 80;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }

        location /api/ {
            proxy_pass http://backend-svc:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
YAML

cat > 06-frontend.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: swr.cn-north-4.myhuaweicloud.com/cloud-course-2023112554/frontend:v1
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-conf
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
      volumes:
        - name: nginx-conf
          configMap:
            name: frontend-nginx-conf
YAML

cat > 07-services.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: redis-svc
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: redis
  ports:
    - port: 6379
      targetPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
YAML

cat > 08-hpa.yaml <<'YAML'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 1
  maxReplicas: 4
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
YAML

kubectl apply -f 01-configmap-secret.yaml
kubectl apply -f 02-pvc.yaml
kubectl apply -f 03-redis.yaml
kubectl apply -f 04-backend.yaml
kubectl apply -f 05-frontend-nginx-configmap.yaml
kubectl apply -f 06-frontend.yaml
kubectl apply -f 07-services.yaml
kubectl apply -f 08-hpa.yaml

kubectl rollout status deploy/redis --timeout=240s
kubectl rollout status deploy/backend --timeout=240s
kubectl rollout status deploy/frontend --timeout=240s

echo
kubectl get pods -o wide
echo
kubectl get svc
echo
kubectl get pvc
echo
kubectl get configmap backend-config frontend-nginx-conf
echo
kubectl get hpa
