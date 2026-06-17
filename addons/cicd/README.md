# 附加题 2：CI/CD 流水线

已生成 GitHub Actions workflow：

```text
.github/workflows/build-push-deploy.yml
```

需要在 GitHub 仓库 Settings -> Secrets and variables -> Actions 中配置：

- `SWR_USERNAME`：SWR 登录用户名，例如 `cn-north-4@...`
- `SWR_PASSWORD`：SWR 登录密码或长期凭据
- `KUBECONFIG_B64`：kubeconfig 的 base64 内容

生成 kubeconfig base64：

```bash
base64 -w 0 cloud-course-2023112554-kubeconfig.yaml
```

流水线阶段：

1. Checkout 代码
2. 登录华为云 SWR
3. 构建 backend/frontend 镜像
4. 推送 `github.sha` 和 `latest` 两个 Tag
5. 使用 kubeconfig 连接 CCE
6. `kubectl set image` 更新 Deployment
7. 等待 rollout 成功并输出 Deployment 镜像

报告截图要求：

- GitHub Actions 全部步骤 Passed
- SWR 镜像 Tag 出现新的 commit sha
- `kubectl get deploy backend frontend -o wide` 显示镜像 Tag 已更新

概念说明：

- CI 持续集成强调代码提交后自动构建、测试和制品生成，尽早发现集成问题。
- CD 持续部署强调制品自动发布到目标环境，减少人工发布风险。
- GitOps 核心是以 Git 仓库作为期望状态唯一来源，由自动化控制器或流水线把集群实际状态收敛到 Git 中声明的状态。
