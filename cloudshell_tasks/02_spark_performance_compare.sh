#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/spark_cloudshell_package"
OUT="$HOME/course-evidence-final/spark_perf_compare"
mkdir -p "$OUT"

run_job() {
  local mode="$1"
  local name="spark-perf-${mode}"
  cat > "${name}.yaml" <<YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: ${name}
  namespace: default
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: ${name}
    spec:
      restartPolicy: Never
      containers:
        - name: spark
          image: apache/spark:3.5.1-python3
          imagePullPolicy: IfNotPresent
          command: ["/opt/spark/bin/spark-submit"]
          args:
            - "--master"
            - "local[${mode}]"
            - "--driver-memory"
            - "768m"
            - "/data/analysis.py"
          env:
            - name: DATA_PATH
              value: "/data/douban_movies.csv"
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "${mode}"
              memory: "1200Mi"
          volumeMounts:
            - name: spark-data
              mountPath: /data
      volumes:
        - name: spark-data
          persistentVolumeClaim:
            claimName: spark-data-pvc
YAML
  kubectl delete job "${name}" --ignore-not-found=true
  kubectl apply -f "${name}.yaml"
  kubectl wait --for=condition=complete "job/${name}" --timeout=1200s
  kubectl logs "job/${name}" > "$OUT/${name}.log"
  grep '\[TIME\]' "$OUT/${name}.log" | tee "$OUT/${name}_times.txt"
}

run_job 1
run_job 2

cat > "$OUT/perf_summary.csv" <<CSV
engine,parallelism,query,seconds
PySpark,1,genre_top10,$(grep 'genre_top10' "$OUT/spark-perf-1_times.txt" | awk -F': ' '{print $2}' | sed 's/s//')
PySpark,2,genre_top10,$(grep 'genre_top10' "$OUT/spark-perf-2_times.txt" | awk -F': ' '{print $2}' | sed 's/s//')
CSV

python3 - <<'PY'
from pathlib import Path
import csv
out = Path.home() / 'course-evidence-final' / 'spark_perf_compare'
rows = list(csv.DictReader((out/'perf_summary.csv').open()))
labels = [f"{r['engine']}-{r['parallelism']}" for r in rows]
values = [float(r['seconds']) for r in rows]
maxv = max(values) if values else 1
w, h = 640, 360
bars = []
for i, (lab, val) in enumerate(zip(labels, values)):
    bw = 160
    x = 120 + i*220
    bh = int((val/maxv)*220)
    y = 280 - bh
    bars.append(f'<rect x="{x}" y="{y}" width="{bw}" height="{bh}" fill="#2f80ed"/>')
    bars.append(f'<text x="{x+bw/2}" y="305" text-anchor="middle" font-size="14">{lab}</text>')
    bars.append(f'<text x="{x+bw/2}" y="{y-8}" text-anchor="middle" font-size="14">{val:.3f}s</text>')
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">
<rect width="100%" height="100%" fill="white"/>
<text x="{w/2}" y="36" text-anchor="middle" font-size="20" font-family="Arial">PySpark Genre Top10 Runtime</text>
<line x1="80" y1="280" x2="580" y2="280" stroke="#333"/>
<line x1="80" y1="60" x2="80" y2="280" stroke="#333"/>
{''.join(bars)}
<text x="30" y="170" transform="rotate(-90 30 170)" text-anchor="middle" font-size="14">Seconds</text>
</svg>'''
(out/'spark_perf_compare.svg').write_text(svg, encoding='utf-8')
print(out/'spark_perf_compare.svg')
PY

cat "$OUT/perf_summary.csv"
echo "Output directory: $OUT"
