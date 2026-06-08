# USE Method — Reference

Source: Brendan Gregg "Systems Performance", Ch. 2. For every resource check:
- **U**tilization — % time busy (or fraction used)
- **S**aturation — queue depth / waiting work
- **E**rrors — error events or rates

## Resource Checklist

| Resource | Utilization | Saturation | Errors | Tools |
|---|---|---|---|---|
| **CPU** | CPU% total and per core | Load average > number of cores | Machine check exceptions | `top`, `mpstat`, `pidstat` |
| **Memory** | Used / Total | Page scan rate (si/so in vmstat) | OOM kills (dmesg) | `free`, `vmstat`, `sar` |
| **Network Interface** | Bytes/s ÷ link bandwidth | TX/RX drops (netstat -s) | Interface errors | `ip -s link`, `sar -n DEV` |
| **Disk I/O** | Device %util (iostat) | Disk queue length (avgqu-sz) | I/O errors (dmesg) | `iostat -xz`, `iotop` |
| **CPU Scheduler** | — | Run queue length (vmstat r) | — | `vmstat`, `sar -q` |
| **File Descriptors** | Open FDs / max (ulimit) | — | EMFILE errors (strace) | `lsof`, `ss` |
| **Mutex / Lock** | % time locked | Thread wait time for lock | Deadlocks | `perf lock`, language profiler |
| **Thread Pool / Worker** | Active workers / pool size | Queue depth | Rejected tasks | Application metrics |
| **DB Connection Pool** | Active connections / pool max | Requests waiting for connection | Connection errors | App metrics, DB stats |

---

## Procedure

```text
1. List all relevant resources (for the affected stack)
2. Per resource: measure U, S, E (tools from above table)
3. Identify bottleneck:
   ├─ Utilization near 100%  → resource is saturated
   ├─ Saturation > 0         → queue is forming
   └─ Errors > 0             → investigate immediately
4. Resource with highest saturation or errors = primary bottleneck
5. Analyze deeper with profiling-specific tools (flamegraph)
```

---

## Quick Diagnosis: Slow Web Service

| Symptom | Suspicion | USE Check |
|---|---|---|
| High latency, low CPU | I/O-bound (DB, disk, network) | Disk: %util, avgqu-sz; Network: drops |
| High CPU, many requests | CPU-bound | CPU: %usr, %sys; Scheduler: run queue |
| Requests standing in queue | Concurrency problem | Thread/worker pool: saturation |
| Memory growing over time | Memory-bound | Memory: Used/Total, page scans, OOM |
| Sporadic spikes | Lock contention or GC pauses | Mutex saturation, GC logs |

---

## p99 vs. Average — Why Average Lies

Average latency can look good while p99 is catastrophic.
Always measure percentiles: p50 (median), p95, p99, p999.

Rule of thumb: p99 is the "worst normal case" — what do 1 in 100 users experience?
