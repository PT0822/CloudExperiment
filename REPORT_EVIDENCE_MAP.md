# 报告证据映射表（最终版）

本文件是根目录快速索引。更完整的解释见 `项目解说_报告撰写指南.md`。

## 总体状态

| 模块 | 状态 | 关键证据 |
|---|---|---|
| 第一部分 1-6 | 已完成 | `evidence/final_verification_after_push_retry.txt`、`evidence/04_public_api_k8s_resources.txt`、`evidence/05_hpa_metrics_verified.txt` |
| Spark A-0 | 已完成 | `evidence/spark_operator/wordcount_keep_executor_pods_final.txt`、`evidence/spark_operator/wordcount_keep_executor_driver_logs.txt` |
| Spark A-1/A-2/A-3 | 已完成 | `evidence/07_spark_analysis_result.txt`、`evidence/spark_perf_compare/perf_summary.csv`、`evidence/spark_perf_compare/spark_perf_compare.svg` |
| 附加题1 监控 | 已完成 | `evidence/shot/grafana_dashboard_monitoring_viewport_2026-06-18.png` |
| 附加题2 CI/CD | 已完成 | `evidence/shot/github_new_anctions_success.png`、`evidence/cicd/github_actions_latest_with_push_retry.txt` |
| 附加题3 MQTT | 已完成（K8s 内云边模拟；若严格要求 K3s，报告需说明或补截图） | `evidence/edge-mqtt/mqtt_qos0_publisher_logs.txt`、`evidence/edge-mqtt/mqtt_qos0_bridge_logs.txt`、`evidence/edge-mqtt/mqtt_qos0_redis_events.txt` |

## 推荐报告入口

1. 先读 `项目解说_报告撰写指南.md`。
2. 再读 `evidence/CURRENT_COMPLETION_MATRIX.md`。
3. 按章节从 `evidence/REPORT_EVIDENCE_MAP.md` 找截图和日志。

## 安全提醒

不要提交或发送 kubeconfig、SWR 密码、华为云账号密码、GitHub token。


## 报告格式补充提醒

- 报告 PDF 需要封面、环境信息、任务 1-6、Spark A-0 到 A-3、总结不少于 200 字、附录。
- 附录建议写 GitHub 仓库链接并列出 YAML、Dockerfile、核心 Python 文件，不要放任何密钥。
- 清理资源前后截图说明见 项目解说_报告撰写指南.md 第 14 节。


## 任务书第六章报告结构映射

| 报告章节 | 对应证据/文件 | 是否已准备 |
|---|---|---|
| 封面 | 小组成员：2023112554 陈沛陶、2023112557 马志凯；班级和日期由报告作者填写 | 待写 PDF 时填写 |
| 华为云环境信息 | `evidence/01_cce_nodes_ready.png`、`evidence/screenshots/集群创建并运行*.png`、`evidence/screenshots/节点创建.png` | 已准备 |
| 第一部分任务 1-6 | `app/`、`k8s/`、`evidence/04_public_api_k8s_resources.txt`、`evidence/05_hpa_metrics_verified.txt`、`evidence/shot/cloudshell_*.png` | 已准备 |
| 第二部分 Spark A | `spark/`、`spark_analysis_result.txt`、`evidence/spark_operator/`、`evidence/spark_perf_compare/` | 已准备 |
| 附加题 | `addons/monitoring/`、`.github/workflows/build-push-deploy.yml`、`addons/edge-mqtt/`、`evidence/monitoring/`、`evidence/cicd/`、`evidence/edge-mqtt/` | 已准备 |
| 总结与收获 | 可引用访问计数、HPA 副本变化、Spark 耗时、CI/CD run id、MQTT events | 待写 PDF 时组织文字 |
| 附录 | GitHub 仓库链接 + `项目解说_报告撰写指南.md` 第 16.6/16.7 节文件索引 | 已准备 |
| 清理说明 | `evidence/cleanup/`、`云资源清理清单_截图说明.md` | 已准备基础截图，ELB/EIP/EVS/OBS/SWR 可继续补充 |
