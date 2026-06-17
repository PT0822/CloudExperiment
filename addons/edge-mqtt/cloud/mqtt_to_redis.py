import json
import os
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt
import redis

MQTT_HOST = os.getenv("MQTT_HOST", "mqtt-broker")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "edge/sensor/temperature")
REDIS_HOST = os.getenv("REDIS_HOST", "redis-svc")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", "")

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD, decode_responses=True)


def on_connect(client, userdata, flags, rc):
    print(f"connected to mqtt rc={rc}", flush=True)
    client.subscribe(MQTT_TOPIC)


def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8")
    key = f"mqtt:last:{msg.topic}"
    r.set(key, payload)
    r.lpush("mqtt:sensor:events", payload)
    r.ltrim("mqtt:sensor:events", 0, 99)
    print(f"stored topic={msg.topic} payload={payload}", flush=True)


client = mqtt.Client(client_id="cloud-mqtt-to-redis")
client.on_connect = on_connect
client.on_message = on_message
while True:
    try:
        client.connect(MQTT_HOST, MQTT_PORT, keepalive=30)
        client.loop_forever()
    except Exception as exc:
        print(f"mqtt bridge error: {exc}", flush=True)
        time.sleep(5)
