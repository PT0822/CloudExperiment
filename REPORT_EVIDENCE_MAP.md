# 报告证据映射表（最终版）

本文件是根目录快速索引。更完整的解释见 `项目解说_报告撰写指南.md`。

## 总体状态

| 模块 | 状态 | 关键证据 |
|---|---|---|
| 第一部分 1-6 | 已完成 | `evidence/final_verification_after_latest_actions.txt`、`evidence/04_public_api_k8s_resources.txt`、`evidence/05_hpa_metrics_verified.txt` |
| Spark A-0 | 已完成 | `evidence/spark_operator/wordcount_keep_executor_pods_final.txt`、`evidence/spark_operator/wordcount_keep_executor_driver_logs.txt` |
| Spark A-1/A-2/A-3 | 已完成 | `evidence/07_spark_analysis_result.txt`、`evidence/spark_perf_compare/perf_summary.csv`、`evidence/spark_perf_compare/spark_perf_compare.svg` |
| 附加题1 监控 | 已完成 | `evidence/shot/grafana_dashboard_monitoring_viewport_2026-06-18.png` |
| 附加题2 CI/CD | 已完成 | `evidence/shot/github_new_anctions_success.png`、`evidence/cicd/github_actions_latest_after_spark_dockerfile.txt` |
| 附加题3 MQTT | 已完成 | `evidence/edge-mqtt/mqtt_qos0_publisher_logs.txt`、`evidence/edge-mqtt/mqtt_qos0_bridge_logs.txt`、`evidence/edge-mqtt/mqtt_qos0_redis_events.txt` |

## 推荐报告入口

1. 先读 `项目解说_报告撰写指南.md`。
2. 再读 `evidence/CURRENT_COMPLETION_MATRIX.md`。
3. 按章节从 `evidence/REPORT_EVIDENCE_MAP.md` 找截图和日志。

## 安全提醒

不要提交或发送 kubeconfig、SWR 密码、华为云账号密码、GitHub token。
