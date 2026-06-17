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
