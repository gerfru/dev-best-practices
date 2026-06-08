---
name: design-observability
description: >
  Observability-Architektur auf Basis der Google SRE Books (Beyer et al.) und
  Observability Engineering (Majors/Fong-Jones, O'Reilly 2022). Deckt
  SLO/SLI/Error-Budget, Golden Signals, Metrics-Design, Distributed Tracing
  (OpenTelemetry), Structured Logging, SLO-basiertes Alerting (Burn Rate) und
  Incident Response Design ab.
  Use this skill whenever the user wants to design or improve observability,
  monitoring, alerting, or reliability engineering for a system.
  Trigger: "Observability einrichten", "SLO definieren", "Monitoring aufbauen",
  "Alerting strategie", "wie messe ich Reliability", "Error Budget berechnen",
  "Distributed Tracing aufsetzen", "SLI definieren", "Incident Response aufbauen",
  "wie erkenne ich Ausfälle früh", "On-Call Design", "Burn Rate Alert",
  "Golden Signals", "strukturiertes Logging", "OpenTelemetry einrichten".
  Deckt ab: SLO/SLI/Error-Budget, Golden Signals, Metrics-Design,
  Distributed Tracing, Structured Logging, SLO-basiertes Alerting, Incident Response.
---

# Observability Design

Entwirft eine vollständige Observability-Architektur von SLO-Definitionen bis zu
Incident-Response-Prozessen — grounded in Google SRE Books und Observability Engineering.

---

## Core Philosophy (Google SRE Books)

> "The Four Golden Signals are latency, traffic, errors, and saturation. If you can
> only measure four metrics of your user-facing system, focus on these four."
> — Google SRE Book, Kap. 6

Observability ist mehr als Monitoring: Monitoring erkennt bekannte Failure-Modi,
Observability ermöglicht das Untersuchen unbekannter Probleme. SLOs sind das Fundament —
sie definieren was "gut genug" ist und damit wann man eingreifen muss.

---

## Schritt 0 — Kontext klären

**Fragen:**
- Service-Typ: HTTP API / Background Worker / Batch Job / Stream Processing?
- Stack: Sprache, Framework, Cloud-Provider, Container-Orchestrierung?
- Bestehendes Monitoring: Was gibt es? (Prometheus, Datadog, CloudWatch, ...)
- SLA-Verpflichtungen: Externe SLAs mit Kunden? Welche Verfügbarkeit zugesichert?
- On-Call: Gibt es eine Rotation? Wer wird heute Nacht geweckt?

→ Kontext notieren. Fehlende Angaben als explizite Annahmen kennzeichnen.

---

## Schritt 1 — SLO / SLI Design

**1a — Golden Signals identifizieren** (→ `references/golden-signals.md`)

Für den Service-Typ die relevanten Golden Signals bestimmen:
Latency, Traffic, Errors, Saturation — jeweils: Wie gemessen? Welche Datenquelle?

**1b — SLIs formulieren**

Pro Golden Signal einen messbaren SLI definieren:
- Format: "% [Requests/Events] die [Bedingung erfüllen]"
- Beispiel: "% HTTP-Requests mit Status < 500 und Latenz < 200ms"
- Vorlagen aus `references/slo-patterns.md` verwenden

**1c — SLO-Ziele und Error Budget**

Pro SLI:
- Prozentziel (z.B. 99.9%)
- Messfenster: rolling 30 Tage (empfohlen)
- Error Budget: `(1 − SLO) × 43.200 min` (Tabelle in `references/slo-patterns.md`)

**1d — Error Budget Policy**

Was passiert wenn das Error Budget aufgebraucht ist?
- Feature-Freeze bis Erholung?
- Pflicht-Reliability-Sprint?
- Stakeholder-Kommunikation?

→ SLO-Dokument zeigen, Nutzer bestätigen bevor weiter.

---

## Schritt 2 — Metrics-Strategie

**2a — Metriken pro Golden Signal**

Für jeden SLI konkrete Metric-Namen, Labels, Typ festlegen:
- Counter: monoton steigend → via `rate()` auswerten
- Histogram: für Latenz (p50/p95/p99 berechenbar)
- Gauge: für Saturation (aktueller Wert)

**2b — Kardinalitäts-Check** (→ `references/golden-signals.md`)

Labels mit hoher Kardinalität eliminieren:
- ❌ `user_id`, `request_id`, `session_id` als Metric-Labels
- ✅ `status_code`, `method`, `route` (< 100 distinct values)
- High-Cardinality-Daten → Tracing, nicht Metrics

**2c — Instrumentierungs-Plan**

OpenTelemetry SDK als Vendor-neutral empfohlen.
Auto-Instrumentierung (HTTP, DB) + manuelle Spans für Business-Logic.

---

## Schritt 3 — Distributed Tracing

**3a — Service-Boundary-Map**

Welche Services kommunizieren miteinander?
Wo entstehen Latenz-Probleme? (Cross-Service-Calls, DB-Queries, externe APIs)

**3b — Span-Design**

- Trace-Context-Propagation: W3C `traceparent` Header
- Span-Attribute nach OTel Semantic Conventions: `http.method`, `http.route`, `db.system`, `error`
- Span-Events für wichtige Zwischenschritte (kein Logging innerhalb von Spans)

**3c — Sampling-Strategie**

- Head-Based Sampling: einfach, verliert seltene/interessante Traces
- Tail-Based Sampling: behält Fehler-Traces, empfohlen für Prod
- Rate: 1–10% normal, 100% für Errors und langsame Requests (> p99-Schwellwert)

---

## Schritt 4 — Log-Strategie

**4a — Structured Logging**

- Format: JSON, immer mit `timestamp` (UTC ISO 8601), `level`, `service`, `trace_id`, `span_id`
- Log-Level-Policy: DEBUG (dev only), INFO (prod-Events), WARN (degraded state), ERROR (Eingriff nötig)
- Library: Pino (Node.js), structlog (Python), zap (Go) — kein `console.log` in Prod

**4b — Trace-Korrelation**

`trace_id` und `span_id` in jeden Log-Eintrag → Logs und Traces verknüpfbar im Observability-Backend

**4c — Retention-Policy**

| Level | Retention |
|---|---|
| DEBUG | 3–7 Tage |
| INFO / WARN | 30 Tage |
| ERROR | 90 Tage |
| Audit-Logs | Gesetzliche Anforderung (oft 1–7 Jahre) |

---

## Schritt 5 — Alert-Design

**5a — SLO-basierte Alerts** (→ `references/alert-runbook.md`)

Alerts auf Burn Rate, nicht auf Symptome:
- Burn Rate > 14.4× in 1h Window → Critical Page
- Burn Rate > 6× in 6h Window → High Page
- Burn Rate > 3× in 24h Window → Ticket

**5b — Alert-Regeln formulieren**

Pro Alert:
- Bedingung (PromQL oder äquivalent)
- Severity (critical / warning / info)
- Runbook-Link (Pflicht — kein Alert ohne Runbook)
- Routing: wer bekommt diesen Alert?

**5c — Alert-Hygiene**

Kein Alert ohne klare Handlungskonsequenz. Regelmäßig prüfen:
- False-Positive-Rate (> 10% → Alert zu aggressiv)
- Alerts die nie feuern (> 3 Monate → löschen oder abschwächen)

---

## Schritt 6 — Incident Response Design

**6a — Runbook pro Alert** (→ `references/alert-runbook.md`)

Template: Symptom → Impact → Diagnose-Schritte → Mitigation → Eskalation.
Runbooks sind lebende Dokumente — nach jedem Incident aktualisieren.

**6b — On-Call-Design**

- Rotation: Minimum 2 Personen im Pool
- Primary → Secondary → Team Lead Eskalation
- Handover-Protokoll: offene Incidents, aktueller Status

**6c — Postmortem-Prozess** (→ `references/alert-runbook.md`)

Blameless Postmortem nach jedem SEV-1 / SEV-2:
- Timeline rekonstruieren
- Action Items mit Owner + Due Date (keine vagen Absichtserklärungen)
- Postmortem-Dokument im Team teilen

---

## Output — `observability-design.md`

```markdown
# Observability Design — [Service Name]

## SLOs
| SLI | SLO | Error Budget (30d) |
|---|---|---|
| [Availability: % Requests < 500] | 99.9% | 43 min |

## Golden Signals
| Signal | Metric | Formel / Quelle |
|---|---|---|
| Latency | http_request_duration_seconds | p95 < 200ms |
| Traffic | http_requests_total | rate[5m] |
| Errors | http_requests_total{status=~"5.."} | % of total |
| Saturation | node_cpu_seconds_total | 1 - idle% |

## Tracing
- Library: OpenTelemetry SDK
- Sampling: Tail-based, 5% normal / 100% errors
- Context Propagation: W3C traceparent

## Logging
- Format: JSON structured
- Library: [Pino / structlog / zap]
- Retention: INFO 30d / ERROR 90d

## Alerts
| Alert | Bedingung | Severity | Runbook |
|---|---|---|---|
| SLOCritical | Burn Rate > 14.4× (1h) | critical | /runbooks/slo-critical |

## Incident Response
- On-Call: [Rotation beschreiben]
- Eskalation: Primary → Secondary → [Team Lead]
- Postmortem: nach SEV-1 / SEV-2, blameless
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → SRE Book / Observability Engineering Kapitel
- `references/slo-patterns.md` — SLO-Vorlagen nach Service-Typ + Error Budget Tabelle
- `references/golden-signals.md` — Golden Signals + PromQL-Muster + Kardinalitäts-Regeln + Burn Rate
- `references/alert-runbook.md` — Burn-Rate-Tabelle, Severity-Matrix, Runbook-Template, Postmortem-Template
