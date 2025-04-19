# gRPC vs REST API Benchmark (Python)

This project benchmarks the performance of gRPC and RESTful APIs implemented in Python under the same conditions. It compares request throughput and latency under a controlled local load test scenario using [Locust](https://locust.io/).

---

## ⚙️ Test Setup

- **Server Environment**: EC2 t3.xlarge (4 vCPU, 16GB RAM)
- **REST Server**: Starlette + Uvicorn (`--workers=1`, later `--workers=2`)
- **gRPC Server**: Python `grpc.server(ThreadPoolExecutor(max_workers=10))`
- **Client**: Locust
- **Payload**: 512KB per request (JSON for REST, Protobuf for gRPC)
- **Locust Parameters**: `-u 100`, `-r 10`, `-t 30s` or `120s`

---

## 🧪 Benchmark Results

### ✅ Initial Test (Single Worker)

| Protocol | Duration | Users | Spawn Rate | Median | 99% | Max | Requests |
|----------|----------|-------|-------------|--------|-----|-----|----------|
| REST (`--workers=1`) | 30s | 100 | 10 | 170ms | 430ms | 4000ms | 9,997 |
| gRPC (`max_workers=10`) | 30s | 100 | 10 | 2ms | 2ms | 27ms | 16,622 |
| REST (`--workers=1`) | 120s | 100 | 10 | 190ms | 440ms | 4100ms | 40,585 |
| gRPC (`max_workers=10`) | 120s | 100 | 10 | 2ms | 2ms | 29ms | 66,796 |

### ✅ Extended Test (High Concurrency, 10,000 users)

| Protocol | Users | Duration | Median | 99% | Max | Requests |
|----------|-------|----------|--------|-----|-----|----------|
| REST | 10,000 | 30s | 320ms | 7000ms | 29,000ms | 10,659 |
| gRPC | 10,000 | 30s | 1ms | 2ms | 45ms | 31,449 |

---

## 🔁 REST Worker Count Scaling Test

To assess how REST server performance changes with multiple workers, we increased Uvicorn's `--workers` from 1 to 2.

### ✅ REST `--workers=2`, `-u 100 -r 10 -t 30s`
- Median: 85ms → better than single-worker 170ms
- Max latency: 240ms → previously 4000ms
- Total Requests: **17,165** → up from 9,997

### ✅ REST `--workers=2`, `-u 100 -r 10 -t 120s`
- Median: 110ms
- Max latency: 190ms
- Total Requests: **63,854**

---

## 📌 Conclusion

- gRPC outperforms REST in both throughput and latency under equal conditions.
- gRPC's ThreadPoolExecutor (`max_workers=10`) handled requests more consistently with very low latency.
- REST performance improved significantly with 2 workers (multi-process), confirming that worker count has a direct impact on Starlette’s performance.
- However, even with 2 workers, REST lagged behind gRPC in total requests and tail latency.

### ⚠️ Limitations

- Tests conducted on `localhost`, meaning HTTP/2 advantages (multiplexing, reduced RTT, header compression) are **not reflected**.
- REST used JSON, gRPC used Protobuf — serialization overhead is different.
- Locust ran on the same instance as the servers, meaning CPU contention may have slightly affected results.
- No CPU/memory profiling was conducted — this could be added in future studies.

---

## 🔧 How to Run
```bash
# Install dependencies
uv pip install -r requirements.txt

# Run REST server
uv run uvicorn rest_server:app

# Run gRPC server
uv run python -m grpc_server

# Run load test
locust -f grpc_locustfile.py --headless -u 100 -r 10 -t 30s
```

---

## 📁 Structure
```
.
├── rest_server.py           # REST server (Starlette)
├── grpc_server.py           # gRPC server (sync)
├── locustfile.py            # REST load test
├── grpc_locustfile.py       # gRPC load test
└── proto/payload.proto      # gRPC schema
```

---

## 🛠️ Future Work
- Test with gRPC async (grpc.aio)
- Measure CPU/memory usage
- Add network simulation (latency, loss)
- Include TLS overhead comparisons
