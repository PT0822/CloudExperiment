#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== create spark data pvc ==="
cat > spark-data-pvc.yaml <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: spark-data-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: csi-disk
  resources:
    requests:
      storage: 10Gi
YAML
kubectl apply -f spark-data-pvc.yaml

cat > spark-data-loader.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: spark-data-loader
  namespace: default
spec:
  restartPolicy: Never
  containers:
    - name: loader
      image: busybox:1.36
      command: ["sh", "-c", "mkdir -p /data && sleep 3600"]
      volumeMounts:
        - name: spark-data
          mountPath: /data
  volumes:
    - name: spark-data
      persistentVolumeClaim:
        claimName: spark-data-pvc
YAML

kubectl delete pod spark-data-loader --ignore-not-found=true
kubectl apply -f spark-data-loader.yaml
kubectl wait --for=condition=Ready pod/spark-data-loader --timeout=180s

echo "=== copy dataset and spark script to pvc ==="
kubectl cp analysis.py spark-data-loader:/data/analysis.py
kubectl cp douban_movies.csv spark-data-loader:/data/douban_movies.csv
kubectl exec spark-data-loader -- sh -c 'ls -lh /data && chmod 644 /data/analysis.py /data/douban_movies.csv'

cat > spark-douban-job.yaml <<'YAML'
apiVersion: batch/v1
kind: Job
metadata:
  name: spark-douban-analysis
  namespace: default
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: spark-douban-analysis
    spec:
      restartPolicy: Never
      containers:
        - name: spark
          image: apache/spark:3.5.1-python3
          imagePullPolicy: IfNotPresent
          command: ["/opt/spark/bin/spark-submit"]
          args: ["--master", "local[*]", "/data/analysis.py"]
          env:
            - name: DATA_PATH
              value: "/data/douban_movies.csv"
          resources:
            requests:
              cpu: "500m"
              memory: "1Gi"
            limits:
              cpu: "2"
              memory: "2Gi"
          volumeMounts:
            - name: spark-data
              mountPath: /data
      volumes:
        - name: spark-data
          persistentVolumeClaim:
            claimName: spark-data-pvc
YAML

echo "=== run spark job ==="
kubectl delete job spark-douban-analysis --ignore-not-found=true
kubectl apply -f spark-douban-job.yaml
kubectl wait --for=condition=complete job/spark-douban-analysis --timeout=1200s

echo "=== spark job status ==="
kubectl get job spark-douban-analysis
kubectl get pods -l app=spark-douban-analysis -o wide

echo "=== spark analysis logs ==="
kubectl logs job/spark-douban-analysis
