# 云计算技术课程设计代码仓库

小组成员：2023112554 陈沛陶、2023112557 马志凯

本仓库用于提交课程设计中修改后的 YAML、Dockerfile、核心 Python 代码和 CI/CD workflow，便于评阅老师按任务书附录要求核验。报告中的运行截图、控制台截图和大体积日志不全部提交到仓库，正文 PDF/DOCX 中已引用关键截图。

## 评阅入口

建议按以下顺序查看：

1. `APPENDIX_INDEX.md`：按任务书“附录：全部修改后的 YAML 文件、Dockerfile 和核心 Python 代码”整理的索引。
2. `app/`：前端、后端与本地 docker compose 联调文件。
3. `k8s/`：第一部分 Kubernetes 资源 YAML，包括 ConfigMap、Secret、PVC、Deployment、Service、HPA。
4. `spark/`：第二部分 Spark 方向 A 的 Dockerfile、SparkApplication 模板、wordcount 示例、数据清洗与查询代码、性能对比代码。
5. `addons/monitoring/`：附加题 1 Prometheus/Grafana 配置。
6. `.github/workflows/build-push-deploy.yml`：附加题 2 GitHub Actions CI/CD 流水线。

## 目录说明

| 路径 | 说明 |
|---|---|
| `app/backend/` | Flask 后端，提供 `/api/ping`、`/api/visit` 等接口 |
| `app/frontend/` | Nginx 前端与反向代理配置 |
| `k8s/` | CCE 部署使用的 Kubernetes YAML |
| `spark/` | PySpark 镜像、SparkApplication 模板、数据分析代码 |
| `spark_cloudshell_package/` | CloudShell 复现实验使用的 Spark 脚本副本 |
| `addons/monitoring/` | kube-prometheus-stack values 与安装命令记录 |
| `addons/cicd/` | CI/CD 说明与注意事项 |
| `.github/workflows/` | GitHub Actions workflow |

## 与报告口径一致的说明

- 第一部分云计算平台搭建已完成，包含镜像构建与推送、CCE 部署、Redis 持久化、ConfigMap/Secret、HPA 等。
- 第二部分选择 Spark 方向 A。`spark/analysis.py` 覆盖数据清洗、GROUP BY 聚合、ORDER BY Top-N、按年份时间趋势、窗口函数查询。
- A-3 性能对比保留 Pandas 与 PySpark local 并行度趋势证据；报告中已说明该口径不等同于完整 SparkApplication executorInstances 对比。
- 附加题最终提交附加题 1 监控系统和附加题 2 CI/CD 流水线。

## 安全说明

仓库不提交 kubeconfig、SWR 密码、华为云账号密码、GitHub token、原始大数据集或大量截图证据。`k8s/01-configmap-secret.yaml` 中的 Secret 字段仅用于演示 Kubernetes Secret 结构，生产环境应使用云厂商密钥管理服务。
