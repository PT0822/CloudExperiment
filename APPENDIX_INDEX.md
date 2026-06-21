# 附录索引：YAML、Dockerfile 与核心 Python 代码

本文件对应任务书第六部分“附录：全部修改后的 YAML 文件、Dockerfile 和核心 Python 代码（或 GitHub 仓库链接）”。仓库地址：<https://github.com/PT0822/CloudExperiment.git>。

## 第一部分：应用与 Kubernetes

| 类型 | 文件 | 对应任务书评分点 |
|---|---|---|
| Backend Dockerfile | `app/backend/Dockerfile.backend` | 后端多阶段构建，Python Flask 运行镜像 |
| Frontend Dockerfile | `app/frontend/Dockerfile.frontend` | 前端 Nginx 静态页镜像 |
| 本地联调 | `app/docker-compose.yml` | 任务 1 docker compose 本地联调 |
| ConfigMap + Secret | `k8s/01-configmap-secret.yaml` | Redis 地址、端口与密码配置注入 |
| PVC | `k8s/02-pvc.yaml` | Redis 持久化存储，10Gi csi-disk RWO |
| Redis Deployment | `k8s/03-redis.yaml` | Redis 单副本与 `/data` PVC 挂载 |
| Backend Deployment | `k8s/04-backend.yaml` | replicas、resources、SWR 镜像、ConfigMap/Secret、探针 |
| Frontend ConfigMap/Deployment | `k8s/05-frontend-nginx-configmap.yaml`, `k8s/06-frontend.yaml` | 前端 Nginx 反向代理与页面部署 |
| Services | `k8s/07-services.yaml` | ClusterIP/LoadBalancer 服务暴露 |
| HPA | `k8s/08-hpa.yaml` | backend-hpa min=1 max=4 CPU 60% |

## 第二部分：Spark 方向 A

| 类型 | 文件 | 对应任务书评分点 |
|---|---|---|
| Spark 镜像 | `spark/Dockerfile.spark` | 将 `analysis.py`、`perf_genre_topn.py`、`wordcount.py` 放入镜像，供 Spark 作业使用 |
| SparkApplication 模板 | `spark/sparkapplication.yaml` | SWR PySpark 镜像、OBS/S3A DATA_PATH、driver/executor 参数 |
| WordCount 示例 | `spark/wordcount.py`, `spark/sparkapplication-wordcount.yaml`, `spark/Dockerfile.wordcount` | A-0 标准模板；报告中说明 Operator 控制器镜像拉取失败，未形成 Completed 运行证据 |
| 豆瓣分析核心代码 | `spark/analysis.py` | A-1/A-2 数据清洗、GROUP BY、ORDER BY Top-N、年份趋势、窗口函数 |
| 性能对比代码 | `spark/pandas_compare.py`, `spark/perf_genre_topn.py` | A-3 性能趋势对比代码；报告中说明 local 并行度口径限制 |
| A-3 SparkApplication 模板 | `spark/sparkapplication-perf-exec1.yaml`, `spark/sparkapplication-perf-exec2.yaml` | executor.instances=1/2 模板，供 Spark Operator 可用时复跑 |
| CloudShell 复现脚本 | `spark/spark-job.yaml`, `spark_cloudshell_package/` | CloudShell 中通过 Kubernetes Job 复现分析结果的脚本 |

## 附加题

| 类型 | 文件 | 对应内容 |
|---|---|---|
| 附加题 1 监控 | `addons/monitoring/install_monitoring.sh`, `addons/monitoring/kube-prometheus-stack-values.yaml` | Prometheus/Grafana 监控系统配置 |
| 附加题 2 CI/CD | `.github/workflows/build-push-deploy.yml`, `addons/cicd/README.md` | GitHub Actions 构建、推送 SWR、更新 CCE Deployment |

## 安全说明

仓库不提交 kubeconfig、SWR 密码、华为云账号密码、GitHub token、原始大数据集和大量截图证据。`k8s/01-configmap-secret.yaml` 中的 base64 字段仅用于演示 Kubernetes Secret 结构，不代表生产环境加密。
