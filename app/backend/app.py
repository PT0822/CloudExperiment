import os
from datetime import datetime, timezone

import redis
from flask import Flask, jsonify


app = Flask(__name__)


def redis_client():
    host = os.getenv("REDIS_HOST", "redis")
    port = int(os.getenv("REDIS_PORT", "6379"))
    password = os.getenv("REDIS_PASSWORD") or None
    return redis.Redis(host=host, port=port, password=password, decode_responses=True)


@app.get("/api/ping")
def ping():
    return jsonify(
        {
            "status": "ok",
            "service": "cloud-course-project",
        "students": "2023112554 陈沛陶, 2023112557 马志凯",
            "time": datetime.now(timezone.utc).isoformat(),
        }
    )


@app.get("/api/visit")
def visit():
    client = redis_client()
    count = client.incr("visit_count")
    return jsonify({"status": "ok", "visit_count": count})


@app.get("/api/redis-test")
def redis_test():
    client = redis_client()
    client.set("testkey", "hello")
    return jsonify({"status": "ok", "testkey": client.get("testkey")})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
