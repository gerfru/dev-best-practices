# Golden Signals — Reference

Source: Google SRE Book, Ch. 6. If only 4 metrics can be measured — these four.

| Signal | Definition | Metric type | PromQL pattern |
|---|---|---|---|
| **Latency** | Time to response — tracked separately for success/error | Histogram | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` |
| **Traffic** | Requests/s or events/s — system load | Counter | `rate(http_requests_total[5m])` |
| **Errors** | % of failed requests (5xx, timeouts, aborted) | Counter | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])` |
| **Saturation** | % of capacity used (CPU, memory, queue depth, disk) | Gauge | `100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |

---

## Metric Types

| Type | When | Example |
|---|---|---|
| **Counter** | Always monotonically increasing, evaluate via `rate()` | `http_requests_total`, `errors_total` |
| **Gauge** | Current value, can increase and decrease | `queue_depth`, `memory_bytes`, `active_connections` |
| **Histogram** | Distribution of values, percentiles computable | `http_request_duration_seconds` |
| **Summary** | Pre-computed percentiles (less flexible than histogram) | Only when histogram is too expensive |

Rule of thumb: **Histogram for latency, Counter for errors/traffic, Gauge for saturation.**

---

## Cardinality Rules

**Never as metric label:**
- `user_id`, `session_id`, `request_id`, `customer_id`
- Anything with > 1000 distinct values

**Allowed as label (< 100 distinct values):**
- `status_code` (200, 404, 500, ...)
- `method` (GET, POST, ...)
- `endpoint` / `route` (only if a limited number of routes)
- `region`, `environment`, `service_name`

**High-cardinality data belongs in traces, not metrics.**

---

## Burn Rate (for SLO-based alerts)

Burn rate = how much faster than normal the error budget is being consumed.

With SLO 99.9% (Error Budget: 43.2 min / 30 days):

| Burn Rate | Meaning | Budget consumed in |
|---|---|---|
| 1× | Normal consumption | 30 days |
| 6× | 6× faster | 5 days |
| 14.4× | Critical | 2 hours |
