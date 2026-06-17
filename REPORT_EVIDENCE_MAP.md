# 报告证据映射表

生成时间：2026-06-18 05:52 +08:00  
小组：2023112554 陈沛陶、2023112557 马志凯

这份文件用于写报告和最后自查。结论按“任务书评分点”逐项核对，不把部分完成说成完全完成。

## 总体状态

| 模块 | 状态 | 说明 |
|---|---|---|
| 第一部分 1-6 | 已完成 | 代码、YAML、CCE 运行状态、截图和日志证据基本齐全 |
| 第二部分 Spark A-1/A-2/A-3 | 已完成 | Spark Job 已在 CCE 完成，清洗、4 类查询、性能对比均有日志/图表 |
| 第二部分 Spark A-0 | 部分完成/风险 | Kubernetes Job 已完成，但任务书严格要求 Spark Operator + SparkApplication Driver/Executor Completed；当前 Spark Operator controller 因 ghcr.io 镜像拉取失败不可用 |
| 附加题 1 监控 | 已完成 | Helm kube-prometheus-stack release + Grafana + Prometheus Dashboard 截图已有 |
| 附加题 2 CI/CD | 未完成真实运行 | workflow 已写好，但缺远程仓库 Actions/Gitee 流水线 Passed 截图和自动更新 Deployment tag 证据 |
| 附加题 3 MQTT | 已完成 | MQTT broker、bridge、publisher、Redis 收到消息均有证据 |

## 第一部分：云计算平台搭建

| 评分点 | 状态 | 证据文件/位置 | 报告要写什么 |
|---|---|---|---|
| Dockerfile.backend 多阶段构建 | 已完成 | app/backend/Dockerfile.backend | 说明 builder 阶段安装依赖，runtime 阶段只复制 packages 和代码 |
| requirements 至少新增 1 个包 | 已完成 | app/backend/requirements.txt，含 requests==2.32.3 | 说明 requests 是额外依赖 |
| 前端首页含学号姓名 | 已完成 | app/frontend/static/index.html | 写明包含两位小组成员学号姓名 |
| docker compose 本地联调 | 已完成 | evidence/screenshots/前端证明1.png、前端证明2.png；app/docker-compose.yml | 放前端访问和后端返回截图 |
| SWR 镜像推送 | 已完成/需报告引用截图 | evidence/screenshots/创建2个镜像.png、2个镜像F&B.png | 截图需能看到 backend/frontend 和 tag |
| CCE 两个 Worker Ready | 已完成 | evidence/01_cce_nodes_ready.png；evidence/live_status_2026-06-18.txt | 截图中要强调 VERSION >= 1.27，当前 v1.33.10 |
| 后端 Deployment 副本、resources、SWR 镜像 | 已完成 | k8s/04-backend.yaml；evidence/live_status_2026-06-18.txt | 说明 replicas=2，requests/limits，镜像来自 SWR |
| Redis Deployment + PVC | 已完成 | k8s/03-redis.yaml；k8s/02-pvc.yaml；evidence/live_status_2026-06-18.txt | 说明 Redis 1 副本，PVC csi-disk，Bound |
| 后端 LoadBalancer + /api/ping | 已完成 | evidence/04_public_api_k8s_resources.txt；evidence/live_status_2026-06-18.txt | 写公网 IP 和 /api/ping 返回 ok |
| Redis ClusterIP | 已完成 | k8s/07-services.yaml；evidence/live_status_2026-06-18.txt | 说明 Redis 只在集群内暴露 |
| ConfigMap + Secret | 已完成 | k8s/01-configmap-secret.yaml；evidence/live_status_2026-06-18.txt | 报告中不要暴露明文密码 |
| Redis 持久化 SET/delete/GET | 已完成 | evidence/shot/cloudshell_补证脚本运行中_*.png；evidence/shot/cloudshell_资源状态_*.png | 放写入、删除 Pod、重建后查询截图 |
| ConfigMap Volume 挂载 | 已完成 | k8s/05-frontend-nginx-configmap.yaml；k8s/06-frontend.yaml；evidence/shot/cloudshell_ConfigMap更新证据_*.png | 说明 volume 挂载文件适合配置文件，envFrom 适合键值环境变量 |
| HPA 扩缩容 | 已完成 | k8s/08-hpa.yaml；evidence/05_hpa_metrics_verified.txt；evidence/shot/cloudshell_HPA*.png | 写 metrics-server 采集周期、HPA 评估间隔、冷却时间防抖、降本价值 |

## 第二部分：Spark 大数据分析

| 评分点 | 状态 | 证据文件/位置 | 报告要写什么 |
|---|---|---|---|
| A-0 Spark Operator 安装 | 部分完成/风险 | evidence/spark_operator/* | 已安装 Helm release 和 CRD，但 controller ImagePullBackOff，原因是 ghcr.io 镜像拉取失败 |
| A-0 Driver + Executor Completed 截图 | 未严格完成 | 当前无 Driver/Executor Completed 截图 | 如老师严格按任务书评分，需要解决 ghcr.io 或拿教师离线包/SWR PySpark 镜像后补跑 |
| A-1 打印 Schema/前 5 行/缺失率 | 已完成 | spark_analysis_result.txt；evidence/07_spark_analysis_result.txt | 截取 Schema、前 5 行、Missing Ratio 表 |
| A-1 两种缺失处理策略 | 已完成 | spark/analysis.py | dropna 处理 rating_score/year；fillna 处理 summary/directors/countries |
| A-1 清洗前后行数和统计信息 | 已完成 | spark_analysis_result.txt；evidence/07_spark_analysis_result.txt | 写 Raw rows、Clean rows、summary 统计 |
| A-2 GROUP BY 聚合 | 已完成 | spark/analysis.py；spark_analysis_result.txt | Query 1 year_trend 或 genre_top10 |
| A-2 ORDER BY Top-N | 已完成 | spark/analysis.py；spark_analysis_result.txt | genre_top10 / country_high_rating |
| A-2 时间维度趋势 | 已完成 | spark/analysis.py；spark_analysis_result.txt | year_trend 按年份统计 |
| A-2 JOIN 或窗口函数 | 已完成 | spark/analysis.py；spark_analysis_result.txt | director_best_movie 使用 row_number window |
| A-3 Pandas vs PySpark 性能图 | 已完成 | evidence/spark_perf_compare/perf_summary.csv；spark_perf_compare.svg | 报告中补 Amdahl 定律分析：数据量、序列化、调度开销导致非线性加速 |

## 附加题 1：监控系统

| 评分点 | 状态 | 证据文件/位置 | 报告要写什么 |
|---|---|---|---|
| kube-prometheus-stack Helm 部署 | 已完成/有说明 | evidence/monitoring/helm_*.txt；evidence/monitoring/kps-light-values.yaml | 说明原始组件受外部镜像影响，保留 Helm release，并用轻量 Prometheus 采集 CCE 节点指标 |
| Prometheus/Grafana Running | 已完成 | evidence/live_status_2026-06-18.txt；evidence/monitoring/monitoring_* | 展示 course-prometheus 与 kps-grafana Running |
| Dashboard：节点 CPU 折线图 | 已完成 | evidence/shot/grafana_dashboard_monitoring_viewport_2026-06-18.png | 插入截图，解释 CPU usage 指标 |
| Dashboard：Pod 内存柱状图 | 已完成 | evidence/shot/grafana_dashboard_monitoring_viewport_2026-06-18.png | 插入截图，解释 working set memory |
| Prometheus Pull 原理和 3 个指标 | 报告待写 | evidence/monitoring/prometheus_query_up.json；dashboard 截图 | 写 Pull 模型、scrape target、up、CPU、memory 三类指标 |

## 附加题 2：CI/CD 流水线

| 评分点 | 状态 | 证据文件/位置 | 下一步 |
|---|---|---|---|
| workflow 文件 | 已完成 | .github/workflows/build-push-deploy.yml；addons/cicd/README.md | 可直接提交到 GitHub/Gitee |
| 自动构建并推送 SWR | 未验证真实流水线 | 当前只有本地 scripts/build_push.sh | 需远程仓库配置 Secrets 后运行 Actions/Gitee 流水线 |
| 自动更新 K8s Deployment | 未验证真实流水线 | workflow 中已有 kubectl set image | 需流水线运行后截图 kubectl get deploy backend frontend -o wide |
| 全部 Passed 截图 | 缺失 | 无 | 必须由你或队友在 GitHub/Gitee 页面截图 |

需要配置的 Secrets：SWR_USERNAME、SWR_PASSWORD、KUBECONFIG_B64。不要把这些值写进仓库或报告。

## 附加题 3：C-2 边缘计算模拟 MQTT

| 评分点 | 状态 | 证据文件/位置 | 报告要写什么 |
|---|---|---|---|
| MQTT Broker Running | 已完成 | evidence/edge-mqtt/mqtt_final_broker_status.txt；evidence/live_status_2026-06-18.txt | 说明云端 K8s 中部署 broker |
| MQTT bridge Running | 已完成 | evidence/edge-mqtt/mqtt_final_bridge_status.txt；mqtt_stdlib_logs_fixed.txt | 说明 bridge 订阅 topic 并写入 Redis |
| Publisher 发布传感器数据 | 已完成 | evidence/edge-mqtt/mqtt_qos0_publisher_logs.txt | 展示 5 条 JSON 传感器消息 |
| Redis 收到 MQTT 数据 | 已完成 | evidence/edge-mqtt/mqtt_qos0_redis_events.txt | 展示 Redis list 中消息 |
| 1500 字专题分析 | 报告待写 | evidence/edge-mqtt/* | 写 MQTT 弱网适用性、QoS、云边协同延迟、局限性；注明本实现用 QoS0 标准库模拟，避免 CCE 内 pip 超时问题 |

## 当前最关键的两个未完成/风险点

1. 附加题 2 必须手动在 GitHub/Gitee 完成真实流水线，因为需要远程仓库和仓库 Secrets。这个我不能凭本地文件伪造。
2. 第二部分 A-0 如果老师严格看 Spark Operator Driver/Executor Completed，就还需要教师提供的离线 Spark Operator 包/镜像，或解决 CCE 拉取 ghcr.io 的网络问题。当前我们已有 Spark Job 完成证据，但不是任务书要求的最标准形式。

## 提交安全提醒

`.gitignore` 已加入，禁止提交 kubeconfig、密钥、压缩包、环境变量文件。提交前执行：

```bash
git status --ignored
```

确认 `cloud-course-2023112554-kubeconfig.yaml` 没有进入 git 暂存区。
