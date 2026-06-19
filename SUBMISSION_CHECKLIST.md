# 提交前检查清单（最终版）

## 已完成

- [x] 第一部分应用容器化、CCE、Deployment/Service、Redis PVC、ConfigMap Volume、HPA。
- [x] 第二部分 Spark A-0：Spark Operator + SparkApplication，Driver/Executor Pod Completed。
- [x] 第二部分 Spark A-1/A-2/A-3：数据清洗、4 类查询、Pandas vs PySpark 性能对比。
- [x] 附加题 1：Prometheus/Grafana 监控和 Dashboard。
- [x] 附加题 2：GitHub Actions CI/CD 成功。
- [x] 附加题 3：MQTT 云边消息链路。
- [x] 临时缩容资源已恢复。
- [x] 项目解说文档已生成：`项目解说_报告撰写指南.md`。

## 还需要人工完成

- [ ] 写实验报告并导出 PDF，封面包含课程名、学号、姓名、班级、日期。
- [ ] 在报告中注明小组成员和分工比例：2023112554 陈沛陶、2023112557 马志凯。
- [ ] 检查截图清晰度和关键信息；所有图表都有编号和标题。
- [ ] 发送提交邮件，附 PDF 和代码仓库链接。
- [ ] 报告确认无误后再清理华为云资源。

## 不能提交或外发

- `cloud-course-2023112554-kubeconfig.yaml`
- SWR 密码、AK/SK
- 华为云账号密码
- GitHub token

## 清理前检查

- [ ] 已保存 CCE、节点、SWR、OBS、ELB、PVC、HPA、Spark、Grafana、GitHub Actions 截图。
- [ ] PDF 初稿已经确认不需要再现场访问公网服务。
- [ ] 按 项目解说_报告撰写指南.md 第 14 节清理资源。


## 报告终稿强制检查

- [ ] PDF 封面包含课程名、题目、学号、姓名、班级、日期。
- [ ] 华为云环境章节写明 Region `cn-north-4`、CCE 版本、节点规格和 2 个 Worker Ready。
- [ ] 第一部分任务 1-6 每节都有：操作步骤摘要、关键配置、截图/日志、问题与解决。
- [ ] 第二部分明确选择方向 A，按 A-0/A-1/A-2/A-3 写，含性能图和 Amdahl 定量分析。
- [ ] 三个附加题分别独立成节；MQTT 专题内容尽量不少于 1500 字，并如实说明 K3s 局限。
- [ ] 总结与收获不少于 200 字，有具体数据，不是泛泛而谈。
- [ ] 附录包含 GitHub 仓库链接和 YAML/Dockerfile/Python 核心文件索引。
- [ ] 附录、正文和截图中没有 kubeconfig、SWR 密码、GitHub token、华为云账号密码。
- [ ] 资源清理章节按实际状态写：已删除、冻结等待释放、或评分后保留，不能夸大为全部手动删除。
