# 云计算技术期末课设执行说明

小组成员：2023112554 陈沛陶、2023112557 马志凯

本目录已经按任务书拆成四部分：本地应用、Kubernetes 部署、Spark 分析、报告截图目录。

## 你必须手动完成的云平台步骤

以下步骤涉及个人账号、实名认证、代金券和云资源权限，不能由脚本代办：

1. 访问教师给出的入班链接，登录华为云/教育科研平台并提交入班申请。
2. 等教师组审核并发放云资源券。
3. 在华为云控制台创建 SWR 组织、CCE 集群、OBS Bucket。
4. 下载 CCE 的 kubeconfig，配置到本地或 CloudShell。
5. 获取教师提供的 Spark Operator Chart、PySpark SWR 镜像地址。

## 本地优先验证

在 WSL Ubuntu 中进入本目录：

```bash
cd /mnt/d/云计算技术/期末课设/app
docker compose up --build
```

浏览器访问 `http://localhost:8080`，后端接口为：

```bash
curl http://localhost:5000/api/ping
curl http://localhost:5000/api/visit
```

## 推送镜像到 SWR

先按华为云控制台信息设置环境变量：

```bash
export SWR_REGION=cn-north-4
export SWR_ORG=<YOUR_ORG>
export SWR_USER='cn-north-4@<AK>'
export SWR_PASSWORD='<SK>'
```

然后执行：

```bash
cd /mnt/d/云计算技术/期末课设
bash scripts/build_push.sh
```

## 部署到 CCE

确认 `kubectl get nodes -o wide` 可看到 2 个 Worker 节点 Ready，然后执行：

```bash
export SWR_REGION=cn-north-4
export SWR_ORG=<YOUR_ORG>
bash scripts/install_helm_wsl.sh
bash scripts/verify_prereqs.sh
bash scripts/deploy_k8s.sh
bash scripts/verify_k8s.sh
```

完整控制台操作见 `CLOUD_RUNBOOK.md`。

## Spark 方向 A

推荐选择方向 A。将数据上传到 OBS 后，把 `spark/sparkapplication.yaml` 中的镜像和参数替换成教师提供值，并在 `spark/analysis.py` 中通过 `DATA_PATH` 指向 OBS 路径，例如：

```text
s3a://<bucket>/douban_movies.csv
```

安装 Spark Operator：

```bash
helm install spark-op ./spark-operator-chart/ -n spark-operator --create-namespace
```

提交作业：

```bash
kubectl apply -f spark/sparkapplication.yaml
kubectl get pods -w
```

## 截图清单

将截图保存到 `report/screenshots/`：

1. SWR 镜像列表。
2. `kubectl get nodes -o wide`。
3. `kubectl get pods` 与 `kubectl get svc`。
4. `/api/ping` 返回 `{"status":"ok"}`。
5. `kubectl get pvc` 显示 Bound。
6. Redis 写入、删除 Pod、重建后读取仍存在。
7. ConfigMap Volume 挂载文件内容。
8. HPA 扩容与缩容。
9. Spark Driver/Executor Pod 与分析输出。
10. Pandas vs PySpark 性能对比图。

## 教师批改入口（最终版）

本仓库用于课程设计代码与配置审阅。报告 PDF 中的截图、日志和运行证据由 `evidence/` 本地目录整理，因包含大量截图和日志，默认不提交到 GitHub；仓库中保留全部修改后的 YAML、Dockerfile、核心 Python 代码和 CI/CD workflow，满足任务书附录要求。

### 建议审阅顺序

1. `APPENDIX_INDEX.md`：任务书第六部分附录索引，列出 YAML、Dockerfile 和核心 Python 代码。
2. `项目解说_报告撰写指南.md`：完整报告撰写说明、任务书逐项核对、附录文件索引。
3. `REPORT_EVIDENCE_MAP.md`：报告证据映射表。
4. `SUBMISSION_CHECKLIST.md`：提交前检查清单。
5. `app/`：前后端应用源码、Dockerfile、本地 docker compose。
6. `k8s/`：第一部分 Kubernetes 资源 YAML。
7. `spark/`：第二部分 Spark 分析代码、SparkApplication、性能对比代码。
8. `addons/`：三个附加题，包含监控、CI/CD 说明、MQTT 云边模拟。
9. `.github/workflows/build-push-deploy.yml`：GitHub Actions CI/CD 流水线。
### 任务书附录对应文件

| 任务书附录要求 | 本仓库对应位置 |
|---|---|
| 全部修改后的 YAML 文件 | `k8s/*.yaml`、`spark/*.yaml`、`addons/monitoring/*.yaml`、`addons/edge-mqtt/cloud/*.yaml`、`.github/workflows/build-push-deploy.yml` |
| Dockerfile | `app/backend/Dockerfile.backend`、`app/frontend/Dockerfile.frontend`、`spark/Dockerfile.spark`、`spark/Dockerfile.wordcount`、`addons/edge-mqtt/cloud/Dockerfile` |
| 核心 Python 代码 | `app/backend/app.py`、`spark/analysis.py`、`spark/pandas_compare.py`、`spark/wordcount.py`、`addons/edge-mqtt/cloud/mqtt_to_redis.py`、`addons/edge-mqtt/edge/sensor_publisher.py` |
| CI/CD | `.github/workflows/build-push-deploy.yml` |
| 报告撰写说明 | `项目解说_报告撰写指南.md` |

### 安全说明

仓库不提交 kubeconfig、SWR 密码、华为云账号密码、GitHub token、原始大数据集和大量截图证据。`k8s/01-configmap-secret.yaml` 中的 Secret 采用 Kubernetes Secret 的 base64 字段形式，仅用于演示配置结构；正式生产环境应改用外部 Secret 管理。


