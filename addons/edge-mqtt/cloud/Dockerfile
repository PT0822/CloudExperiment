FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir paho-mqtt==1.6.1 redis==5.0.1
COPY mqtt_to_redis.py /app/mqtt_to_redis.py
CMD ["python", "mqtt_to_redis.py"]
