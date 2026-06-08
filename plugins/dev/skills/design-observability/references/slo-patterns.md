# SLO Patterns — nach Service-Typ

## Error Budget Rechner

`Error Budget (min) = (1 − SLO) × 30 × 24 × 60`

| SLO | Error Budget / 30 Tage |
|---|---|
| 99.0% | 432 min (7.2h) |
| 99.5% | 216 min (3.6h) |
| 99.9% | 43.2 min |
| 99.95% | 21.6 min |
| 99.99% | 4.3 min |

---

## HTTP API (synchron)

| SLI | SLO | Empfehlung |
|---|---|---|
| Availability: % Requests mit Status < 500 | 99.9% | Standard für interne APIs |
| Latency: % Requests < 200ms | 95% | p95-Ziel |
| Latency: % Requests < 1000ms | 99% | absolutes Maximum |
| Error Rate: % Requests mit Status 5xx | < 0.1% | direkt aus Availability ableitbar |

## Background Worker / Queue Consumer

| SLI | SLO | Empfehlung |
|---|---|---|
| Success Rate: % Jobs ohne Error abgeschlossen | 99.5% | toleriert gelegentliche Retries |
| Throughput: Jobs/min ≥ Schwellwert | 95% in 5-min-Fenstern | Stau-Früherkennung |
| Latency: % Jobs abgeschlossen in < X sec | 90% | je nach Criticality |

## Batch Job

| SLI | SLO | Empfehlung |
|---|---|---|
| Completion: % Runs abgeschlossen in SLA-Fenster | 99% | z.B. Nacht-Batch bis 6 Uhr |
| Freshness: Daten nicht älter als X Stunden | 99.5% | für Downstream-Abhängigkeiten |
| Correctness: % Outputs validiert korrekt | 99.9% | wo prüfbar |

## Stream Processing

| SLI | SLO | Empfehlung |
|---|---|---|
| Consumer Lag: < X Messages | 99% | verhindert Stau |
| End-to-End Latency: Event → Output < X sec | 95% | |
| Error Rate: % Events mit Processing-Fehler | < 0.5% | |

## Datenbank (intern genutzt)

| SLI | SLO | Empfehlung |
|---|---|---|
| Query Latency p99 < X ms | 99% | z.B. < 50ms für OLTP |
| Availability (Connection erfolreich) | 99.95% | höher als abhängige Services |
