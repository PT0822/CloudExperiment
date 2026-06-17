# 附加题 1：监控系统

目标：用 kube-prometheus-stack 部署 Prometheus + Grafana，并截图证明：

- monitoring 命名空间 Pod Running
- Grafana Dashboard 显示节点 CPU 利用率折线图
- Grafana Dashboard 显示各 Pod 内存使用柱状图

CloudShell 执行：

```bash
cd ~/addons/monitoring
bash install_monitoring.sh ./kube-prometheus-stack
```

如果没有离线 chart，脚本会尝试在线 Helm repo。

Grafana 登录：

- 用户名：admin
- 密码：admin123

报告指标说明建议：

- `node_cpu_seconds_total`：节点 CPU 按模式累计使用时间，可通过 rate 计算 CPU 使用率。
- `container_memory_working_set_bytes`：容器当前实际工作集内存，适合展示 Pod 内存占用。
- `kube_pod_status_phase`：Pod 生命周期阶段，用于观察 Running/Pending/Failed 状态。

Prometheus Pull 原理：Prometheus 按配置周期性访问各 Exporter 或 ServiceMonitor 暴露的 `/metrics` HTTP 端点，将时序样本写入本地 TSDB；Grafana 通过 PromQL 查询 Prometheus 并渲染图表。
