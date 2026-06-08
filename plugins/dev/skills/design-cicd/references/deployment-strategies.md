# Deployment-Strategien — Vergleich

| Strategie | Beschreibung | Downtime | Rollback | Infra-Kosten | Risiko |
|---|---|---|---|---|---|
| **Recreate** | Alte Version stoppen, neue starten | Ja | Neues Deployment | 1× | Hoch |
| **Rolling Update** | Instanzen schrittweise ersetzen | Nein | Rollout stoppen / rückwärts | 1× | Mittel |
| **Blue-Green** | Zwei parallele Envs, Traffic-Switch | Nein | Traffic zurückschalten | 2× | Niedrig |
| **Canary** | % Traffic auf neue Version, schrittweise erhöhen | Nein | Traffic auf 0% | 1.x× | Niedrig |
| **Feature Flags** | Code deployed, Feature per Flag aktiviert | Nein | Flag deaktivieren | 1× | Minimal |
| **Shadow** | Prod-Traffic auf neue Version spiegeln (kein User-Impact) | Nein | Kein Traffic-Impact | 1.x× | Keins |

---

## Entscheidungsbaum

```text
Kann es Downtime geben?
├─ Ja → Recreate (nur für Non-Prod / Low-Traffic)
└─ Nein:
   Neue Version + alte Version API-kompatibel?
   ├─ Unsicher / Breaking Change → Feature Flag
   └─ Kompatibel:
      Brauche ich granulares Rollout-Feedback?
      ├─ Ja → Canary (mit Metrics-Gate)
      └─ Nein:
         Reicht schnelles Rollback via Traffic-Switch?
         ├─ Ja → Blue-Green
         └─ Nein → Rolling Update
```

---

## Feature Flags — Entscheidung

**Verwende Feature Flags wenn:**
- Neues Feature unsicher ob production-stable
- Breaking Change an bestehender API (beide Versionen parallel betreiben)
- A/B-Test oder graduelle Einführung nach User-Segmenten
- Kill-Switch für sofortiges Rollback ohne Deployment nötig

**Nicht verwenden wenn:**
- Rein technische Refactorings ohne Behavior-Change
- Feature ist bereits vollständig getestet und stabil
- Zu viele Flags akkumulieren sich (Tech-Debt: Flags löschen nach Rollout)

---

## Canary Release — Rollout-Plan

| Phase | Traffic % | Warte auf | Abbruch wenn |
|---|---|---|---|
| 1 | 1% | 30 min, Error Rate stabil | Error Rate > Baseline + 0.1% |
| 2 | 10% | 1h, Latenz stabil | p95 Latenz > Baseline + 20% |
| 3 | 50% | 2h, DORA Metriken stabil | CFR steigt |
| 4 | 100% | — | — |
