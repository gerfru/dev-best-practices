# LLM Integration Patterns — Entscheidungsmatrix

## Wann welches Pattern?

| Pattern | Wählen wenn... | Nicht wählen wenn... |
|---|---|---|
| **Prompting-only** | Aufgabe mit Kontext lösbar, kein externes Wissen nötig, schnelles Prototyping | Wissen muss aktuell/domänenspezifisch sein, Verhalten muss konsistent angepasst sein |
| **RAG** | Wissens-Bottleneck: Modell kennt Inhalte nicht (Docs, DB, aktuelle Daten), kein Fine-tuning-Budget | Aufgabe braucht keine externe Wissensquelle, Latenz-kritisch ohne Caching |
| **Fine-tuning** | Verhaltens-Bottleneck: Stil/Format/Ton muss konsistent angepasst sein, viele Beispiele vorhanden, Production-Volume hoch | Wissen fehlt (→ RAG), Budget klein, wenige Beispiele (<500) |
| **Agent / Tool-Use** | Mehrere Schritte, externe Aktionen nötig (APIs, Code-Ausführung, Search), Aufgabe nicht mit einem LLM-Call lösbar | Einfache Q&A, Latenz-kritisch, Kosten-kritisch |

**Faustregel (CMU 11-667):** Prompt → RAG → Fine-tune → Agent. Immer mit dem einfachsten Pattern starten.

---

## Pattern-Kombinationen (häufig in Produktion)

| Kombination | Typischer Use-Case |
|---|---|
| RAG + Prompting | Dokumenten-Q&A, Knowledge-Base-Chat |
| Fine-tune + RAG | Domänen-Assistent mit spezifischem Stil + aktuellem Wissen |
| Agent + RAG | Deep Research, Code-Generierung mit Dokumentations-Zugriff |
| Agent + Fine-tune | Spezialisierter Code-Agent (z.B. SQL-Agent) |

---

## Kosten-/Latenz-Profil

| Pattern | Latenz (p95) | Kosten/Request | Wartungsaufwand |
|---|---|---|---|
| Prompting-only | Niedrig (1 LLM-Call) | Gering | Minimal |
| RAG | Mittel (+Retrieval-Latenz) | Mittel (+Embedding-Calls) | Mittel (Index-Pflege) |
| Fine-tune | Niedrig (kleineres Modell möglich) | Niedrig (kleineres Modell) | Hoch (Retraining) |
| Agent | Hoch (multiple LLM-Calls) | Hoch (N × Token-Kosten) | Hoch (Tool-Integration) |

---

## Referenzen

| Entscheidung | Quelle |
|---|---|
| Prompting vs. Fine-tune | CMU 11-667 Lec 4 — "Deciding when to finetune and finetuning efficiently" |
| RAG-Grundlagen | CMU 11-667 Lec 5–7 — "Retrieval 1–3: Storing, RAG, Deep Research" |
| Multi-Agent | CMU 11-667 Lec 14 — "Multi-agent systems" |
| Tool-Use | CMU 11-667 Lec 11 — "Tool-use, chitchat, personas" |
| Agent Frameworks | Berkeley CS294-196 Lec (Oct 7) — "Compound AI Systems & DSPy" (Omar Khattab) |
| Inference-Optimierung | MIT 6.5940 Lec 13 — "Efficient LLM Deployment" |
