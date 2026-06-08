# Golden Signals — Referenz

Quelle: Google SRE Book, Kap. 6. Wenn nur 4 Metriken messbar sind — diese vier.

| Signal | Definition | Metric-Typ | PromQL-Muster |
|---|---|---|---|
| **Latency** | Zeit bis zur Antwort — getrennt nach success/error | Histogram | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` |
| **Traffic** | Requests/s oder Events/s — Systemlast | Counter | `rate(http_requests_total[5m])` |
| **Errors** | % fehlgeschlagener Requests (5xx, Timeouts, aborted) | Counter | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])` |
| **Saturation** | % genutzter Kapazität (CPU, Memory, Queue Depth, Disk) | Gauge | `100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |

---

## Metric-Typen

| Typ | Wann | Beispiel |
|---|---|---|
| **Counter** | Immer monoton steigend, via `rate()` auswerten | `http_requests_total`, `errors_total` |
| **Gauge** | Aktueller Wert, kann steigen und fallen | `queue_depth`, `memory_bytes`, `active_connections` |
| **Histogram** | Verteilung von Werten, Percentile berechenbar | `http_request_duration_seconds` |
| **Summary** | Vorberechnete Percentile (weniger flexibel als Histogram) | Nur wenn Histogram zu teuer |

Faustregel: **Histogram für Latenz, Counter für Fehler/Traffic, Gauge für Saturation.**

---

## Kardinalitäts-Regeln

**Niemals als Metric-Label:**
- `user_id`, `session_id`, `request_id`, `customer_id`
- Alles mit > 1000 distinct values

**Erlaubt als Label (< 100 distinct values):**
- `status_code` (200, 404, 500, ...)
- `method` (GET, POST, ...)
- `endpoint` / `route` (nur wenn begrenzte Anzahl Routes)
- `region`, `environment`, `service_name`

**High-Cardinality-Daten gehören in Traces, nicht Metrics.**

---

## Burn Rate (für SLO-basierte Alerts)

Burn Rate = wie viel schneller als normal das Error Budget verbraucht wird.

Bei SLO 99.9% (Error Budget: 43.2 min / 30 Tage):

| Burn Rate | Bedeutung | Budget verbraucht in |
|---|---|---|
| 1× | Normalverbrauch | 30 Tage |
| 6× | 6× schneller | 5 Tage |
| 14.4× | Kritisch | 2 Stunden |
