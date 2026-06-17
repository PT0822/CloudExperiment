# 提交前检查清单

## 不能提交到 GitHub/Gitee 的内容
- cloud-course-2023112554-kubeconfig.yaml
- 任何 SWR 密码、华为云账号密码、Access Key、Secret Key
- 临时压缩包和下载包

## 附加题 2 CI/CD 仍需手动完成
1. 在 GitHub 或 Gitee 创建远程仓库。
2. 推送本目录代码，但确认 `.gitignore` 已生效。
3. 在仓库 Actions/Secrets 中配置：
   - SWR_USERNAME
   - SWR_PASSWORD
   - KUBECONFIG_B64
4. 触发 `.github/workflows/build-push-deploy.yml`。
5. 截图保存：流水线全部 Passed、SWR 镜像 tag、CCE Deployment 镜像 tag 更新。

## 当前已完成证据索引
- 完成矩阵：evidence/CURRENT_COMPLETION_MATRIX.md
- Grafana 截图：evidence/shot/grafana_dashboard_monitoring_viewport_2026-06-18.png
- MQTT 证据：evidence/edge-mqtt/
- Spark 结果：spark_analysis_result.txt 与 evidence/spark_perf_compare/
