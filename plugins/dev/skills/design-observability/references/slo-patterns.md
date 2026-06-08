# SLO Patterns — by Service Type

## Error Budget Calculator

`Error Budget (min) = (1 − SLO) × 30 × 24 × 60`

| SLO | Error Budget / 30 days |
|---|---|
| 99.0% | 432 min (7.2h) |
| 99.5% | 216 min (3.6h) |
| 99.9% | 43.2 min |
| 99.95% | 21.6 min |
| 99.99% | 4.3 min |

---

## HTTP API (synchronous)

| SLI | SLO | Recommendation |
|---|---|---|
| Availability: % requests with status < 500 | 99.9% | Standard for internal APIs |
| Latency: % requests < 200ms | 95% | p95 target |
| Latency: % requests < 1000ms | 99% | Absolute maximum |
| Error rate: % requests with status 5xx | < 0.1% | Directly derivable from availability |

## Background Worker / Queue Consumer

| SLI | SLO | Recommendation |
|---|---|---|
| Success rate: % jobs completed without error | 99.5% | Tolerates occasional retries |
| Throughput: jobs/min ≥ threshold | 95% in 5-min windows | Early queue backlog detection |
| Latency: % jobs completed in < X sec | 90% | Depends on criticality |

## Batch Job

| SLI | SLO | Recommendation |
|---|---|---|
| Completion: % runs completed within SLA window | 99% | e.g. nightly batch by 6am |
| Freshness: data not older than X hours | 99.5% | For downstream dependencies |
| Correctness: % outputs validated correct | 99.9% | Where verifiable |

## Stream Processing

| SLI | SLO | Recommendation |
|---|---|---|
| Consumer lag: < X messages | 99% | Prevents backlog |
| End-to-end latency: event → output < X sec | 95% | |
| Error rate: % events with processing error | < 0.5% | |

## Database (internally used)

| SLI | SLO | Recommendation |
|---|---|---|
| Query latency p99 < X ms | 99% | e.g. < 50ms for OLTP |
| Availability (connection successful) | 99.95% | Higher than dependent services |
