---
name: dev:tool-perf
description: >
  Performance engineering workflow grounded in MIT 6.172 (Leiserson/Shun,
  fully available on MIT OCW) and "Systems Performance" (Brendan Gregg,
  Addison-Wesley 2020). Covers USE Method (Utilization/Saturation/Errors),
  flamegraph analysis, bottleneck identification, Bentley Rules, and
  measurable before/after benchmarking.
  Use this skill whenever the user has a performance problem, slow code,
  high latency, CPU/memory spikes, or wants to optimize a system.
  Trigger: "performance problem", "slow API", "high latency", "CPU spike",
  "memory leak", "analyze flamegraph", "find bottleneck", "optimize code",
  "profiling", "p99 too high", "increase throughput", "USE Method",
  "why is this so slow", "load test shows problems".
  Covers: USE Method, flamegraph analysis, CPU/memory/I-O/network profiling,
  Bentley Rules, measurement and benchmarking.
---

# Performance Engineering (tool-perf)

Structured performance analysis workflow — from symptom description to
verified fix. Grounded in MIT 6.172 and Brendan Gregg "Systems Performance".

---

## Core Philosophy (MIT 6.172 + Brendan Gregg)

> "Measure, don't guess." — Core principle of performance engineering
>
> "Never tune for performance without first having a performance target."
> — Brendan Gregg, Systems Performance

Always measure before optimizing. Without profiling data, optimization is guessing.
USE Method provides the systematic framework — flamegraphs show WHERE time is spent.

---

## Step 0 — Clarify Scope and Symptom

**Questions:**
- What is the concrete symptom? (High latency / high CPU / memory growth / low throughput)
- Stack: web service / CLI / database / low-level C/C++ / JVM / Python?
- Are there metrics? (Prometheus, Datadog, APM tool, when did it get worse?)
- Is there a performance target? (p99 < 200ms, throughput > 1000 req/s)
- Production problem or pre-release optimization?

→ Without concrete numbers and a target, performance work cannot be completed.

---

## Step 1 — USE Method: Locate the Bottleneck

(→ `references/use-method.md` for complete resource checklist)

**Measure for each relevant resource:**
- Utilization: How many % of capacity is being used?
- Saturation: Are queues forming?
- Errors: Are there error events?

**Quick diagnosis by symptom:**

| Symptom | Suspicion | Next step |
|---|---|---|
| High latency, low CPU | I/O-bound | Disk queue, network drops, DB latency |
| High CPU, scales with traffic | CPU-bound | CPU profiling, flamegraph |
| Requests queueing | Concurrency limit | Thread/worker pool saturation |
| Memory growing over time | Memory leak | Heap dump, allocation profiling |
| Sporadic spikes | Lock contention or GC | Mutex saturation, GC logs |

→ Identify the most likely bottleneck, then analyze deeper.

---

## Step 2 — Profiling and Flamegraph

**2a — Choose profiling tool (by stack)**

| Stack | CPU Profiler | Memory Profiler |
|---|---|---|
| Linux (C/C++/Go) | `perf record + perf report` | Valgrind, heaptrack |
| JVM (Java/Kotlin/Scala) | async-profiler, JFR | JVM Heap Dump + Eclipse MAT |
| Python | `py-spy`, `cProfile` | memory-profiler, Tracemalloc |
| Node.js | `--prof`, Clinic.js | `--inspect` + Chrome DevTools |
| Go | `pprof` | `pprof` Heap Profile |
| Browser (JS) | Chrome DevTools Performance | Chrome DevTools Memory |

**2b — Create and read flamegraph**

```text
perf record -F 99 -g -- <command>
perf script | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

Reading a flamegraph:
- X-axis = share of total sampling time (not time progression)
- Y-axis = call stack (bottom = entry point, top = where time is spent)
- Width of a block = % time in that function + callees
- Plateau (wide flat block at top) = hotspot — optimize there

**2c — Identify top hotspot**

Locate the widest block at the very top of the flamegraph.
That is the function consuming the most CPU time.

---

## Step 3 — Bottleneck Analysis

**CPU-bound:**
- Algorithm complexity (O(n²) where O(n log n) possible?)
- Apply Bentley Rules (→ `references/bentley-rules.md`)
- Cache efficiency: check memory access pattern (row-major vs column-major)
- Parallelization: single-threaded bottleneck → multi-threading

**Memory-bound:**
- Heap profiling: which allocations dominate?
- Reduce GC pressure: object pooling, fewer short-lived objects
- Memory leak: which objects grow over time?

**I/O-bound:**
- DB queries: EXPLAIN ANALYZE, missing indexes, N+1 queries
- Disk: async I/O, batching, sequential instead of random access
- Network: connection pooling, keep-alive, compression

**Lock contention:**
- Minimize critical section
- Lock-free data structures where possible
- Read-write lock instead of exclusive mutex

---

## Step 4 — Optimization with Bentley Rules

(→ `references/bentley-rules.md` for complete rules)

**Before optimizing:** Record baseline benchmark (exact numbers).

Priority by impact:
1. **Algorithm/data structure** — greatest impact (O(n²) → O(n log n))
2. **Caching** — expensive computations done once
3. **Loop optimizations** — hoisting, fusion, early exit
4. **Memory access patterns** — cache friendliness

**Never optimize without measurement** (premature optimization).

---

## Step 5 — Measurement and Verification

**5a — Record benchmark**

Always: measure before optimization, measure after optimization.
Same conditions, sufficient runs (separate warmup + measurement phase).

**5b — Benchmark tools**

| Type | Tool |
|---|---|
| Microbenchmark | JMH (Java), criterion (Rust), benchmark (Go), pytest-benchmark |
| HTTP load test | k6, wrk, hey, Apache Bench |
| Profiler-based | Compare flamegraph before/after |
| System level | `perf stat` (CPU cycles, cache misses, instructions) |

**5c — Document results**

| Metric | Before | After | Improvement |
|---|---|---|---|
| p50 latency | X ms | Y ms | Z% |
| p99 latency | X ms | Y ms | Z% |
| Throughput (req/s) | X | Y | Z% |
| CPU (%) | X | Y | Z% |

---

## Output — `perf-findings.md`

```markdown
# Performance Findings — [Service/Component]

## Symptom
[Concrete description: p99 latency 800ms, target < 200ms]

## USE Method Results
| Resource | U | S | E | Finding |
|---|---|---|---|---|
| CPU | 85% | Load 4 (2 Cores) | 0 | CPU-bound |
| Memory | 60% | 0 | 0 | OK |

## Root Cause
[Flamegraph shows: 73% time in `parseJson()` — inefficient parser]

## Action
[Switch to faster JSON parser, cache result]

## Measurement Results
| Metric | Before | After |
|---|---|---|
| p99 latency | 800ms | 120ms |
| CPU | 85% | 35% |
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → MIT 6.172 lecture + Brendan Gregg chapter
- `references/use-method.md` — Resource checklist (U/S/E), quick diagnosis, p99 vs. average
- `references/bentley-rules.md` — Data structure / logic / loop / memory optimization rules
