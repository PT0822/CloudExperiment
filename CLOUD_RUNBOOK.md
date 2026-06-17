# 华为云控制台操作清单

本文件只记录需要你在浏览器控制台手动完成的步骤。不要把华为云登录密码、AK/SK、SK 明文提交到报告或仓库。

## 1. 确认代金券

进入费用中心后检查：

- 代金券状态为可用。
- 适用区域优先选择 `cn-north-4`，后续 SWR/CCE/OBS 都尽量保持同一区域。
- 截图保存到账页或资源券页，放到 `report/screenshots/`。

## 2. 创建 SWR 组织

控制台搜索 `SWR 容器镜像服务`：

1. 选择区域 `华北-北京四 cn-north-4`。
2. 创建组织，例如 `cloud-course-2023112554`。
3. 记下组织名，后续作为 `SWR_ORG`。
4. 在控制台查看登录命令和推送命令模板。

本地后续需要设置：

```bash
export SWR_REGION=cn-north-4
export SWR_ORG=<你的组织名>
export SWR_USER='cn-north-4@<AK>'
export SWR_PASSWORD='<SK>'
```

## 3. 创建 CCE 集群

控制台搜索 `CCE 云容器引擎`：

1. 创建 Kubernetes 集群，版本选择 `>= 1.27`。
2. 网络插件使用默认 `Yangtse CNI`。
3. 创建 2 个 Worker 节点，建议规格 `2 vCPU / 4 GB`。
4. 集群创建完成后，进入连接信息，下载 kubeconfig 或使用 CloudShell。
5. 截图 `kubectl get nodes -o wide`，要求 Worker 状态为 `Ready` 且含 `VERSION` 列。

## 4. 创建 OBS Bucket

控制台搜索 `OBS 对象存储服务`：

1. 区域选择 `cn-north-4`。
2. 创建 bucket，例如 `cloud-course-2023112554`。
3. 上传 `douban_movies.csv`。
4. Spark 中使用路径：

```text
s3a://<bucket-name>/douban_movies.csv
```

## 5. 教师材料

还需要从课程群或共享目录拿到：

- `spark-operator-chart/`
- 教师提供的 PySpark SWR 镜像地址
- 如做附加题 1，还需要 `kube-prometheus-stack` Helm Chart 离线包

拿到后放到本目录，建议路径：

```text
期末课设/
  spark-operator-chart/
  kube-prometheus-stack/
```

## 6. 云上部署顺序

完成以上控制台步骤后，在 WSL 中执行：

```bash
cd /mnt/d/云计算技术/期末课设
bash scripts/install_helm_wsl.sh
bash scripts/verify_prereqs.sh
bash scripts/build_push.sh
bash scripts/deploy_k8s.sh
bash scripts/verify_k8s.sh
```

然后按 `README.md` 的截图清单收集报告材料。
