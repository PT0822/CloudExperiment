# 附加题 3：C-2 边缘计算模拟：K3s + MQTT

选题：C-2。目标是模拟边缘节点周期性产生传感器数据，通过 MQTT Broker 发布到云端 K8s，再由云端消费者写入 Redis。

## 组件

- 边缘端：`edge/sensor_publisher.py`，使用 `paho-mqtt` 发布温湿度数据。
- 云端 MQTT Broker：`cloud/mqtt-broker.yaml`，部署 Mosquitto。
- 云端写入服务：`cloud/mqtt_to_redis.py`，订阅 MQTT 并写入 `redis-svc`。
- Redis：复用第一部分 Redis。

## 云端部署

构建并推送桥接镜像：

```bash
cd addons/edge-mqtt/cloud
docker build -t mqtt-to-redis:v1 -t swr.cn-north-4.myhuaweicloud.com/cloud-course-2023112554/mqtt-to-redis:v1 .
docker push swr.cn-north-4.myhuaweicloud.com/cloud-course-2023112554/mqtt-to-redis:v1
```

CloudShell 部署：

```bash
kubectl apply -f mqtt-broker.yaml
kubectl apply -f mqtt-to-redis.yaml
kubectl rollout status deploy/mqtt-broker
kubectl rollout status deploy/mqtt-to-redis
```

## 边缘端运行

如果在本地 K3s/WSL 中运行边缘端，需要能访问云端 MQTT Broker。可临时用 `kubectl port-forward` 验证：

```bash
kubectl port-forward svc/mqtt-broker 1883:1883
pip install paho-mqtt
MQTT_HOST=127.0.0.1 python edge/sensor_publisher.py
```

验证 Redis：

```bash
REDIS_POD=$(kubectl get pod -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$REDIS_POD" -- sh -c 'redis-cli -a "$REDIS_PASSWORD" LRANGE mqtt:sensor:events 0 4'
```

## 报告要点

MQTT 使用发布/订阅模型，边缘设备只需要连接 Broker 并向 Topic 发布数据，不需要知道云端消费者的位置。QoS 1 可以在弱网环境下提供“至少一次”投递语义，但可能产生重复消息，需要云端根据 device_id/seq 去重。云边协同的主要延迟来自边缘网络抖动、Broker 排队、云端消费者处理和 Redis 写入；相比 HTTP 轮询，MQTT 长连接和轻量报文更适合低带宽、不稳定网络中的传感器数据上报。
