# Alert & Runbook — Referenz

## Burn Rate Alert Tabelle (SLO 99.9%, Error Budget 43.2 min/30d)

| Alert Name | Burn Rate | Window | Budget konsumiert | Severity | Response |
|---|---|---|---|---|---|
| SLOCritical | > 14.4× | 1h | ~3 min | Page sofort | < 5 min |
| SLOHigh | > 6× | 6h | ~36 min | Page | < 30 min |
| SLOMedium | > 3× | 24h | ~6h | Ticket | nächster Tag |
| SLOLow | > 1× | 72h | Slow burn | Info | Sprint-Backlog |

Für andere SLOs: Burn Rate = `(1 - SLO) × Budget_total / Alert_window`

---

## Alert Severity Matrix

| Severity | Wann | Response-Zeit | Wer |
|---|---|---|---|
| **Critical (Page)** | Sofortiger Eingriff nötig, User-Impact jetzt | < 5 min | On-Call Primary |
| **High (Page)** | Eingriff in < 1h nötig, drohender User-Impact | < 30 min | On-Call Primary |
| **Warning (Ticket)** | Nächsten Arbeitstag beheben | < 24h | Team |
| **Info** | Kein Eingriff nötig, nur zur Kenntnis | — | Niemand pagen |

---

## Runbook-Template (pro Alert)

```markdown
# Runbook: [Alert-Name]

**Alert-Bedingung:** [PromQL / Bedingung]
**Severity:** Critical / High / Warning

## Symptom
Was sieht der On-Call? (Dashboard-Link, typische Fehlermeldung)

## Impact
- Betroffene User / Features:
- SLO-Impact: [ja/nein, wie viel Budget]

## Diagnose
1. [Dashboard-Link] prüfen: [was man dort sieht]
2. [Query oder Log-Suche]
3. [Nächster Diagnoseschritt]

## Mitigation
- Schnellster Workaround: [Schritt]
- Permanenter Fix: [Schritt oder Ticket]

## Eskalation
Wenn Mitigation nicht hilft nach [X min] → [Name/Rolle] kontaktieren
```

---

## Postmortem-Template (nach SEV-1 / SEV-2)

```markdown
# Postmortem: [Incident-Titel]

**Datum:** [Datum]
**Dauer:** [Start] – [Ende] ([X] Minuten)
**Severity:** SEV-1 / SEV-2
**SLO-Verletzung:** ja/nein — [X min Error Budget konsumiert]

## Impact
- Betroffene User:
- Betroffene Features / Services:

## Root Cause
[Was ist passiert — 5-Why oder Fishbone]

## Contributing Factors
[Systemische Ursachen, die den Incident möglich gemacht haben]

## Timeline
| Zeit | Ereignis |
|---|---|
| HH:MM | [Was passiert ist] |
| HH:MM | [Erkennung durch ...] |
| HH:MM | [Erste Maßnahme] |
| HH:MM | [Resolved] |

## Detection
- Erkannt durch: [Alert / User-Report / Monitoring]
- Zeit bis zur Erkennung: [X min]
- Hätte früher erkannt werden können: ja/nein — [wie?]

## Action Items
| Task | Owner | Due Date |
|---|---|---|
| [Konkrete Maßnahme, kein "wir sollten..."] | [Name] | [Datum] |

## Lessons Learned
- Was hat funktioniert:
- Was hat nicht funktioniert:
- Was ändern wir am Prozess:
```
