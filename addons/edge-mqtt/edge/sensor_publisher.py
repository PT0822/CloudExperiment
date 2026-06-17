import json
import os
import random
import socket
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt

MQTT_HOST = os.getenv("MQTT_HOST", "127.0.0.1")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "edge/sensor/temperature")
DEVICE_ID = os.getenv("DEVICE_ID", socket.gethostname())

client = mqtt.Client(client_id=f"edge-sensor-{DEVICE_ID}")
client.connect(MQTT_HOST, MQTT_PORT, keepalive=30)

for seq in range(1, 31):
    payload = {
        "device_id": DEVICE_ID,
        "seq": seq,
        "temperature": round(20 + random.random() * 10, 2),
        "humidity": round(40 + random.random() * 20, 2),
        "ts": datetime.now(timezone.utc).isoformat(),
    }
    body = json.dumps(payload, ensure_ascii=False)
    client.publish(MQTT_TOPIC, body, qos=1)
    print(body, flush=True)
    time.sleep(1)

client.disconnect()
