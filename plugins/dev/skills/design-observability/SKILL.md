---
name: dev:design-observability
description: >
  Observability architecture grounded in the Google SRE Books (Beyer et al.) and
  Observability Engineering (Majors/Fong-Jones, O'Reilly 2022). Covers
  SLO/SLI/Error Budget, Golden Signals, metrics design, distributed tracing
  (OpenTelemetry), structured logging, SLO-based alerting (burn rate), and
  incident response design.
  Use this skill whenever the user wants to design or improve observability,
  monitoring, alerting, or reliability engineering for a system.
  Trigger: "set up observability", "define SLO", "build monitoring",
  "alerting strategy", "how do I measure reliability", "calculate error budget",
  "set up distributed tracing", "define SLI", "build incident response",
  "how do I detect outages early", "on-call design", "burn rate alert",
  "golden signals", "structured logging", "set up OpenTelemetry".
  Covers: SLO/SLI/Error Budget, Golden Signals, metrics design,
  distributed tracing, structured logging, SLO-based alerting, incident response.
---

# Observability Design

Designs a complete observability architecture from SLO definitions to
incident response processes — grounded in Google SRE Books and Observability Engineering.

---

## Core Philosophy (Google SRE Books)

> "The Four Golden Signals are latency, traffic, errors, and saturation. If you can
> only measure four metrics of your user-facing system, focus on these four."
> — Google SRE Book, Ch. 6

Observability is more than monitoring: monitoring detects known failure modes,
observability enables investigating unknown problems. SLOs are the foundation —
they define what "good enough" is and therefore when to intervene.

---

## Step 0 — Clarify Context

**Questions:**
- Service type: HTTP API / background worker / batch job / stream processing?
- Stack: language, framework, cloud provider, container orchestration?
- Existing monitoring: what is in place? (Prometheus, Datadog, CloudWatch, ...)
- SLA obligations: external SLAs with customers? What availability is committed?
- On-call: Is there a rotation? Who gets paged tonight?

→ Note context. Flag missing information as explicit assumptions.

---

## Step 1 — SLO / SLI Design

**1a — Identify Golden Signals** (→ `references/golden-signals.md`)

Determine the relevant golden signals for the service type:
Latency, Traffic, Errors, Saturation — for each: how measured? what data source?

**1b — Formulate SLIs**

Define a measurable SLI per golden signal:
- Format: "% [requests/events] that [satisfy condition]"
- Example: "% HTTP requests with status < 500 and latency < 200ms"
- Use templates from `references/slo-patterns.md`

**1c — SLO Targets and Error Budget**

Per SLI:
- Percentage target (e.g. 99.9%)
- Measurement window: rolling 30 days (recommended)
- Error budget: `(1 − SLO) × 43,200 min` (table in `references/slo-patterns.md`)

**1d — Error Budget Policy**

What happens when the error budget is exhausted?
- Feature freeze until recovery?
- Mandatory reliability sprint?
- Stakeholder communication?

→ Show SLO document, confirm with user before proceeding.

---

## Step 2 — Metrics Strategy

**2a — Metrics per Golden Signal**

For each SLI define concrete metric names, labels, and type:
- Counter: monotonically increasing → evaluate via `rate()`
- Histogram: for latency (p50/p95/p99 computable)
- Gauge: for saturation (current value)

**2b — Cardinality Check** (→ `references/golden-signals.md`)

Eliminate labels with high cardinality:
- ❌ `user_id`, `request_id`, `session_id` as metric labels
- ✅ `status_code`, `method`, `route` (< 100 distinct values)
- High-cardinality data → tracing, not metrics

**2c — Instrumentation Plan**

OpenTelemetry SDK recommended as vendor-neutral.
Auto-instrumentation (HTTP, DB) + manual spans for business logic.

---

## Step 3 — Distributed Tracing

**3a — Service Boundary Map**

Which services communicate with each other?
Where do latency problems arise? (cross-service calls, DB queries, external APIs)

**3b — Span Design**

- Trace context propagation: W3C `traceparent` header
- Span attributes per OTel Semantic Conventions: `http.method`, `http.route`, `db.system`, `error`
- Span events for important intermediate steps (no logging inside spans)

**3c — Sampling Strategy**

- Head-based sampling: simple, loses rare/interesting traces
- Tail-based sampling: retains error traces, recommended for prod
- Rate: 1–10% normal, 100% for errors and slow requests (> p99 threshold)

---

## Step 4 — Logging Strategy

**4a — Structured Logging**

- Format: JSON, always with `timestamp` (UTC ISO 8601), `level`, `service`, `trace_id`, `span_id`
- Log level policy: DEBUG (dev only), INFO (prod events), WARN (degraded state), ERROR (intervention needed)
- Library: Pino (Node.js), structlog (Python), zap (Go) — no `console.log` in prod

**4b — Trace Correlation**

`trace_id` and `span_id` in every log entry → logs and traces linkable in observability backend

**4c — Retention Policy**

| Level | Retention |
|---|---|
| DEBUG | 3–7 days |
| INFO / WARN | 30 days |
| ERROR | 90 days |
| Audit logs | Legal requirement (often 1–7 years) |

---

## Step 5 — Alert Design

**5a — SLO-Based Alerts** (→ `references/alert-runbook.md`)

Alerts on burn rate, not on symptoms:
- Burn rate > 14.4× in 1h window → critical page
- Burn rate > 6× in 6h window → high page
- Burn rate > 3× in 24h window → ticket

**5b — Formulate Alert Rules**

Per alert:
- Condition (PromQL or equivalent)
- Severity (critical / warning / info)
- Runbook link (required — no alert without a runbook)
- Routing: who receives this alert?

**5c — Alert Hygiene**

No alert without a clear action consequence. Review regularly:
- False positive rate (> 10% → alert too aggressive)
- Alerts that never fire (> 3 months → delete or soften)

---

## Step 6 — Incident Response Design

**6a — Runbook per Alert** (→ `references/alert-runbook.md`)

Template: Symptom → Impact → Diagnosis steps → Mitigation → Escalation.
Runbooks are living documents — update after every incident.

**6b — On-Call Design**

- Rotation: minimum 2 people in the pool
- Primary → Secondary → Team lead escalation
- Handover protocol: open incidents, current status

**6c — Postmortem Process** (→ `references/alert-runbook.md`)

Blameless postmortem after every SEV-1 / SEV-2:
- Reconstruct timeline
- Action items with owner + due date (no vague statements of intent)
- Share postmortem document with the team

---

## Output — `observability-design.md`

```markdown
# Observability Design — [Service Name]

## SLOs
| SLI | SLO | Error Budget (30d) |
|---|---|---|
| [Availability: % requests < 500] | 99.9% | 43 min |

## Golden Signals
| Signal | Metric | Formula / Source |
|---|---|---|
| Latency | http_request_duration_seconds | p95 < 200ms |
| Traffic | http_requests_total | rate[5m] |
| Errors | http_requests_total{status=~"5.."} | % of total |
| Saturation | node_cpu_seconds_total | 1 - idle% |

## Tracing
- Library: OpenTelemetry SDK
- Sampling: Tail-based, 5% normal / 100% errors
- Context propagation: W3C traceparent

## Logging
- Format: JSON structured
- Library: [Pino / structlog / zap]
- Retention: INFO 30d / ERROR 90d

## Alerts
| Alert | Condition | Severity | Runbook |
|---|---|---|---|
| SLOCritical | Burn rate > 14.4× (1h) | critical | /runbooks/slo-critical |

## Incident Response
- On-call: [describe rotation]
- Escalation: Primary → Secondary → [Team Lead]
- Postmortem: after SEV-1 / SEV-2, blameless
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → SRE Book / Observability Engineering chapter
- `references/slo-patterns.md` — SLO templates by service type + error budget table
- `references/golden-signals.md` — Golden Signals + PromQL patterns + cardinality rules + burn rate
- `references/alert-runbook.md` — Burn rate table, severity matrix, runbook template, postmortem template
