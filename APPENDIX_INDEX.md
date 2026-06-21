# 附录索引：YAML、Dockerfile 与核心 Python 代码

本文件用于对应任务书第六部分“附录：全部修改后的 YAML 文件、Dockerfile 和核心 Python 代码（或 GitHub 仓库链接）”。仓库地址：<https://github.com/PT0822/CloudExperiment.git>。

## 第一部分：应用与 Kubernetes

| 类型 | 文件 | 对应任务书模板/评分点 |
|---|---|---|
| Backend Dockerfile | `app/backend/Dockerfile.backend` | 附录 A-1，多阶段构建，Python Flask |
| Frontend Dockerfile | `app/frontend/Dockerfile.frontend` | 附录 A-1，Nginx 静态页 |
| 本地联调 | `app/docker-compose.yml` | 任务 1 docker compose 本地联调 |
| ConfigMap + Secret | `k8s/01-configmap-secret.yaml` | 附录 A-2，Redis 地址与密码注入 |
| PVC | `k8s/02-pvc.yaml` | 附录 A-3，10Gi csi-disk RWO |
| Redis Deployment | `k8s/03-redis.yaml` | 任务 3/4，Redis 单副本与 `/data` 挂载 |
| Backend Deployment | `k8s/04-backend.yaml` | 附录 A-2，replicas=2、resources、SWR 镜像、ConfigMap/Secret、livenessProbe |
| Frontend ConfigMap/Deployment | `k8s/05-frontend-nginx-configmap.yaml`, `k8s/06-frontend.yaml` | 前端反向代理扩展，不替代后端评分项 |
| Services | `k8s/07-services.yaml` | 后端 LoadBalancer、Redis ClusterIP，另含前端 LoadBalancer |
| HPA | `k8s/08-hpa.yaml` | 附录 A-4，backend-hpa min=1 max=4 CPU 60% |

## 第二部分：Spark 方向 A

| 类型 | 文件 | 对应任务书模板/评分点 |
|---|---|---|
| Spark 镜像 | `spark/Dockerfile.spark` | 将 `analysis.py`、`perf_genre_topn.py`、`wordcount.py` 放入 `/opt/spark/work/`，供 SparkApplication 使用 |
| SparkApplication | `spark/sparkapplication.yaml` | 附录 B-1，SWR PySpark 镜像、executor instances=2、memory=1g |
| WordCount 示例 | `spark/wordcount.py`, `spark/sparkapplication-wordcount.yaml`, `spark/Dockerfile.wordcount` | A-0 Driver/Executor Completed 验证；SparkApplication 模板保留 executor instances=2、memory=1g |
| 豆瓣分析核心代码 | `spark/analysis.py` | A-1/A-2，清洗后保留 56889 行，并输出 4 个 SQL/DataFrame 查询 |
| 性能对比代码 | `spark/pandas_compare.py`, `spark/perf_genre_topn.py` | A-3，同一 Genre 聚合查询的 Pandas 单机与 PySpark 对比 |
| A-3 SparkApplication | `spark/sparkapplication-perf-exec1.yaml`, `spark/sparkapplication-perf-exec2.yaml` | A-3，分别设置 executor.instances=1 和 executor.instances=2 |
| CloudShell 兜底 Job | `spark/spark-job.yaml`, `spark_cloudshell_package/` | 当 SparkApplication 受镜像/资源限制时的云端可运行作业证据 |

## 附加题

| 类型 | 文件 | 对应内容 |
|---|---|---|
| 监控 | `addons/monitoring/install_monitoring.sh`, `addons/monitoring/kube-prometheus-stack-values.yaml` | Prometheus/Grafana |
| CI/CD | `.github/workflows/build-push-deploy.yml`, `addons/cicd/README.md` | GitHub Actions 构建、推送 SWR、更新 CCE |
| MQTT | `addons/edge-mqtt/cloud/*.yaml`, `addons/edge-mqtt/cloud/mqtt_to_redis.py`, `addons/edge-mqtt/edge/sensor_publisher.py` | MQTT broker、bridge、publisher 和 Redis 消息链路 |

## 安全说明

仓库不应提交 kubeconfig、SWR 密码、华为云账号密码、GitHub token、原始大数据集和大量截图证据。`k8s/01-configmap-secret.yaml` 中的 base64 字段仅用于演示 Kubernetes Secret 结构，不代表生产环境加密。
