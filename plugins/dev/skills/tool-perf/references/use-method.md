# USE Method — Referenz

Quelle: Brendan Gregg "Systems Performance", Kap. 2. Fuer jede Ressource pruefen:
- **U**tilization — % Zeit busy (oder Anteil genutzt)
- **S**aturation — Queue-Tiefe / wartende Arbeit
- **E**rrors — Fehler-Events oder -Raten

## Ressourcen-Checkliste

| Ressource | Utilization | Saturation | Errors | Tools |
|---|---|---|---|---|
| **CPU** | CPU% gesamt und pro Core | Load Average > Anzahl Cores | Machine Check Exceptions | `top`, `mpstat`, `pidstat` |
| **Memory** | Used / Total | Page Scan Rate (si/so in vmstat) | OOM-Kills (dmesg) | `free`, `vmstat`, `sar` |
| **Network Interface** | Bytes/s ÷ Link-Bandwidth | TX/RX Drops (netstat -s) | Interface Errors | `ip -s link`, `sar -n DEV` |
| **Disk I/O** | Device %util (iostat) | Disk Queue Length (avgqu-sz) | I/O Errors (dmesg) | `iostat -xz`, `iotop` |
| **CPU Scheduler** | — | Run Queue Length (vmstat r) | — | `vmstat`, `sar -q` |
| **File Descriptors** | Open FDs / Max (ulimit) | — | EMFILE Errors (strace) | `lsof`, `ss` |
| **Mutex / Lock** | % Zeit gelockt | Thread-Wartezeit auf Lock | Deadlocks | `perf lock`, Language Profiler |
| **Thread Pool / Worker** | Active Workers / Pool Size | Queue-Tiefe | Rejected Tasks | Application Metrics |
| **DB Connection Pool** | Active Connections / Pool Max | Requests warten auf Connection | Connection Errors | App Metrics, DB Stats |

---

## Vorgehen

```text
1. Alle relevanten Ressourcen auflisten (fuer den betroffenen Stack)
2. Pro Ressource: U, S, E messen (Tools aus obiger Tabelle)
3. Engpass identifizieren:
   ├─ Utilization nahe 100%  → Ressource ist saturiert
   ├─ Saturation > 0         → Warteschlange bildet sich
   └─ Errors > 0             → Sofort untersuchen
4. Ressource mit hoechster Saturation oder Errors = primaerer Bottleneck
5. Tiefer analysieren mit profilierungs-spezifischen Tools (Flamegraph)
```

---

## Schnell-Diagnose: Web-Service langsam

| Symptom | Verdacht | USE-Check |
|---|---|---|
| Hohe Latenz, niedrige CPU | I/O-bound (DB, Disk, Network) | Disk: %util, avgqu-sz; Network: Drops |
| Hohe CPU, viele Requests | CPU-bound | CPU: %usr, %sys; Scheduler: Run Queue |
| Requests stehen in Queue | Concurrency-Problem | Thread/Worker Pool: Saturation |
| Speicherlecks (Anstieg ueber Zeit) | Memory-bound | Memory: Used/Total, Page Scans, OOM |
| Sporadische Spikes | Lock Contention oder GC Pauses | Mutex Saturation, GC Logs |

---

## p99 vs. Average — Warum Average luegt

Durchschnittliche Latenz kann gut aussehen waehrend p99 katastrophal ist.
Immer Percentiles messen: p50 (median), p95, p99, p999.

Faustregel: p99 ist der "worst normal case" — was erleben 1 von 100 Nutzern?
