---
name: tool-perf
description: >
  Performance Engineering Workflow grounded in MIT 6.172 (Leiserson/Shun,
  vollstaendig auf MIT OCW) und "Systems Performance" (Brendan Gregg,
  Addison-Wesley 2020). Deckt USE Method (Utilization/Saturation/Errors),
  Flamegraph-Analyse, Bottleneck-Identifikation, Bentley Rules und
  messbares Before/After-Benchmarking ab.
  Use this skill whenever the user has a performance problem, slow code,
  high latency, CPU/memory spikes, or wants to optimize a system.
  Trigger: "Performance-Problem", "langsame API", "hohe Latenz", "CPU-Spike",
  "Memory-Leak", "Flamegraph analysieren", "Bottleneck finden", "Code optimieren",
  "Profiling", "p99 zu hoch", "Throughput erhoehen", "USE Method",
  "warum ist das so langsam", "Load Test zeigt Probleme".
  Deckt ab: USE Method, Flamegraph-Analyse, CPU/Memory/I-O/Network Profiling,
  Bentley Rules, Measurement und Benchmarking.
---

# Performance Engineering (tool-perf)

Strukturierter Performance-Analyse-Workflow — von der Symptom-Beschreibung bis zum
verifizierten Fix. Grounded in MIT 6.172 und Brendan Gregg "Systems Performance".

---

## Core Philosophy (MIT 6.172 + Brendan Gregg)

> "Measure, don't guess." — Grundprinzip Performance Engineering
>
> "Never tune for performance without first having a performance target."
> — Brendan Gregg, Systems Performance

Immer messen bevor optimiert wird. Ohne Profiling-Daten ist Optimierung Raten.
USE Method gibt den systematischen Rahmen — Flamegraphs zeigen WO die Zeit verbracht wird.

---

## Schritt 0 — Scope und Symptom klären

**Fragen:**
- Was ist das konkrete Symptom? (Hohe Latenz / hoher CPU / Memory-Wachstum / niedrige Throughput)
- Stack: Web-Service / CLI / Datenbank / Low-Level C/C++ / JVM / Python?
- Gibt es Metriken? (Prometheus, Datadog, APM-Tool, ab wann schlechter?)
- Gibt es ein Performance-Ziel? (p99 < 200ms, Throughput > 1000 req/s)
- Produktions-Problem oder pre-release Optimierung?

→ Ohne konkrete Zahlen und Ziel ist Performance-Arbeit nicht abschliessbar.

---

## Schritt 1 — USE Method: Bottleneck lokalisieren

(→ `references/use-method.md` fuer vollstaendige Ressourcen-Checkliste)

**Fuer jede relevante Ressource messen:**
- Utilization: Wie viel % der Kapazitaet wird genutzt?
- Saturation: Bilden sich Warteschlangen?
- Errors: Gibt es Fehler-Events?

**Schnell-Diagnose nach Symptom:**

| Symptom | Verdacht | Naechster Schritt |
|---|---|---|
| Hohe Latenz, niedrige CPU | I/O-bound | Disk-Queue, Network-Drops, DB-Latenz |
| Hohe CPU, skaliert mit Traffic | CPU-bound | CPU-Profiling, Flamegraph |
| Requests in Queue | Concurrency-Limit | Thread/Worker Pool Saturation |
| Memory steigt ueber Zeit | Memory-Leak | Heap Dump, Allocation Profiling |
| Sporadische Spikes | Lock Contention oder GC | Mutex Saturation, GC Logs |

→ Den wahrscheinlichsten Bottleneck identifizieren, dann tiefer analysieren.

---

## Schritt 2 — Profiling und Flamegraph

**2a — Profiling-Tool waehlen (nach Stack)**

| Stack | CPU Profiler | Memory Profiler |
|---|---|---|
| Linux (C/C++/Go) | `perf record + perf report` | Valgrind, heaptrack |
| JVM (Java/Kotlin/Scala) | async-profiler, JFR | JVM Heap Dump + Eclipse MAT |
| Python | `py-spy`, `cProfile` | memory-profiler, Tracemalloc |
| Node.js | `--prof`, Clinic.js | `--inspect` + Chrome DevTools |
| Go | `pprof` | `pprof` Heap Profile |
| Browser (JS) | Chrome DevTools Performance | Chrome DevTools Memory |

**2b — Flamegraph erstellen und lesen**

```text
perf record -F 99 -g -- <command>
perf script | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

Flamegraph lesen:
- X-Achse = Anteil der gesamten Sampling-Zeit (nicht Zeit-Verlauf)
- Y-Achse = Call Stack (unten = Entry Point, oben = wo Zeit verbracht wird)
- Breite eines Blocks = % Zeit in dieser Funktion + Callees
- Plateau (breiter flacher Block oben) = Hotspot — dort optimieren

**2c — Top-Hotspot identifizieren**

Den breitesten Block ganz oben im Flamegraph lokalisieren.
Das ist die Funktion die am meisten CPU-Zeit verbraucht.

---

## Schritt 3 — Bottleneck-Analyse

**CPU-bound:**
- Algorithmus-Komplexitaet (O(n²) wo O(n log n) moeglich?)
- Bentley Rules anwenden (→ `references/bentley-rules.md`)
- Cache-Effizienz: Memory-Access-Pattern pruefen (Row-major vs Column-major)
- Parallelisierung: Single-threaded Bottleneck → Multi-threading

**Memory-bound:**
- Heap-Profiling: welche Allokationen dominieren?
- GC-Druck reduzieren: Object-Pooling, weniger kurzlebige Objekte
- Memory-Leak: Welche Objekte wachsen ueber Zeit?

**I/O-bound:**
- DB-Queries: EXPLAIN ANALYZE, fehlende Indexe, N+1-Queries
- Disk: Async I/O, Batching, Sequential statt Random Access
- Network: Connection Pooling, Keep-Alive, Compression

**Lock Contention:**
- Kritische Sektion minimieren
- Lock-freie Datenstrukturen wo moeglich
- Read-Write Lock statt exklusivem Mutex

---

## Schritt 4 — Optimierung mit Bentley Rules

(→ `references/bentley-rules.md` fuer vollstaendige Regeln)

**Vor der Optimierung:** Baseline-Benchmark aufnehmen (exakte Zahlen).

Prioritaet nach Hebelwirkung:
1. **Algorithmus/Datenstruktur** — groesste Wirkung (O(n²) → O(n log n))
2. **Caching** — teure Berechnungen einmalig
3. **Loop-Optimierungen** — Hoisting, Fusion, Early Exit
4. **Memory-Zugriffspattern** — Cache-Freundlichkeit

**Niemals ohne Messung optimieren** (Premature Optimization).

---

## Schritt 5 — Measurement und Verification

**5a — Benchmark aufnehmen**

Immer: vor der Optimierung messen, nach der Optimierung messen.
Gleiche Bedingungen, ausreichend Durchlaeufe (Warmup + Messphase trennen).

**5b — Benchmark-Tools**

| Typ | Tool |
|---|---|
| Microbenchmark | JMH (Java), criterion (Rust), benchmark (Go), pytest-benchmark |
| HTTP Load Test | k6, wrk, hey, Apache Bench |
| Profiler-basiert | Flamegraph before/after vergleichen |
| System-Level | `perf stat` (CPU cycles, cache misses, instructions) |

**5c — Ergebnis dokumentieren**

| Metrik | Vorher | Nachher | Verbesserung |
|---|---|---|---|
| p50 Latenz | X ms | Y ms | Z% |
| p99 Latenz | X ms | Y ms | Z% |
| Throughput (req/s) | X | Y | Z% |
| CPU (%) | X | Y | Z% |

---

## Output — `perf-findings.md`

```markdown
# Performance Findings — [Service/Component]

## Symptom
[Konkrete Beschreibung: p99 Latenz 800ms, Ziel < 200ms]

## USE Method Ergebnis
| Ressource | U | S | E | Befund |
|---|---|---|---|---|
| CPU | 85% | Load 4 (2 Cores) | 0 | CPU-bound |
| Memory | 60% | 0 | 0 | OK |

## Root Cause
[Flamegraph zeigt: 73% Zeit in `parseJson()` — ineffizienter Parser]

## Massnahme
[Wechsel zu schnellerem JSON-Parser, Ergebnis cachen]

## Messergebnis
| Metrik | Vorher | Nachher |
|---|---|---|
| p99 Latenz | 800ms | 120ms |
| CPU | 85% | 35% |
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → MIT 6.172 Lecture + Brendan Gregg Kapitel
- `references/use-method.md` — Ressourcen-Checkliste (U/S/E), Schnell-Diagnose, p99 vs. Average
- `references/bentley-rules.md` — Datenstruktur / Logik / Loop / Memory Optimierungsregeln
