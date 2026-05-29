---
name: debug-specialist
description: Stack-aware Debugging-Assistent. Analysiert einen Fehler oder ein unerwartetes Verhalten, erkennt automatisch Stack/Framework und liefert einen strukturierten Root-Cause-Plan mit konkreten Fix-Vorschlägen. Use this skill whenever the user reports a bug, error message, unexpected behavior, or asks "why does X not work"; triggert bei "Fehler", "Error", "funktioniert nicht", "debug", "warum gibt es X", Stack Trace oder unerwartete Ausgaben.
---

# Debug Specialist (stack-aware)

Analysiert einen Fehler kontextbewusst: erkennt zuerst den Stack, dann den Fehler-Typ,
dann die wahrscheinlichste Ursache. Keine generischen Checklisten — nur was für diesen
Stack und diesen Fehler relevant ist.

## Schritt 0 — Kontext & Stack erkennen

Scanne das Projekt automatisch (nie raten, nie annehmen):

**Sprache & Runtime:**
- `package.json` → Node.js/TypeScript, Framework (Next.js, Express, Fastify, NestJS …)
- `pyproject.toml` / `requirements.txt` → Python, Framework (FastAPI, Django, Flask …)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java/Kotlin

**Deployment & Infrastruktur:**
- `Dockerfile` / `docker-compose.yml` → Container-Kontext, Netzwerk-Aliase, Volumes
- `.github/workflows/` → CI-Pipeline, Build-Schritte
- `CLAUDE.md` des Projekts → dokumentierte Ausnahmen, bekannte Probleme

**Fehler-Kontext vom Nutzer erfassen:**
- Fehlermeldung / Stack Trace (falls nicht gegeben: einmal nachfragen)
- Wann tritt er auf (Start / Laufzeit / Build / Test)?
- Reproduzierbar oder intermittierend?
- Was hat sich zuletzt geändert?

## Schritt 1 — Fehler klassifizieren

Ordne den Fehler einer Kategorie zu und passe die Analyse an:

| Kategorie | Typische Ursachen | Wo suchen |
|---|---|---|
| **Import / Dependency** | falsche Version, fehlender Peer-Dep, zirkulärer Import | package.json / lock file, Import-Reihenfolge |
| **Konfiguration** | fehlende Env-Var, falscher Pfad, Type Mismatch in Config | .env, config-Files, Startup-Logs |
| **Netzwerk / API** | falscher Port, CORS, Auth-Header fehlt, Timeout | Docker-Netzwerk, Proxy-Config, Request-Headers |
| **Datenbank** | Migration nicht gelaufen, Connection Pool erschöpft, Query-Fehler | Migration-History, Connection-String, Query-Logs |
| **Async / Concurrency** | Race Condition, unbehandeltes Promise, Deadlock | Event Loop, async/await Kette, Locking |
| **Type / Schema** | Nullpointer, Schema-Mismatch, falsches Format | Typen, Validierung (Zod/Pydantic), Serialisierung |
| **Build / Compile** | Transpile-Fehler, fehlende Typen, Tree-Shaking | tsconfig, Bundler-Config, Import-Pfade |
| **Umgebungsunterschied** | "funktioniert lokal" → Container/CI anders | Env-Vars, Node/Python-Version, Pfad-Trennzeichen |

## Schritt 2 — Root-Cause-Analyse

1. **Lese die relevanten Dateien** (nicht alle — nur die, die zur Fehler-Kategorie passen)
2. **Trace den Fehler-Pfad** von der Fehlermeldung rückwärts durch die Aufrufkette
3. **Prüfe die häufigsten Ursachen** für diesen Stack + diese Kategorie
4. **Formuliere 1-3 Hypothesen** mit Konfidenz (hoch/mittel/niedrig) und Begründung

Stack-spezifische Checks (nur wenn relevant):

**Next.js / React:**
- Server vs. Client Component Grenze verletzt?
- `use client` / `use server` Direktive korrekt?
- Hydration-Mismatch (Server-/Client-Render unterschiedlich)?
- `.env.local` vs. `.env.production` — Variable exposed?

**FastAPI / Python:**
- Pydantic-Schema-Mismatch (v1 vs. v2 API)?
- Async-Fehler: `await` fehlt, sync-Funktion in async-Kontext?
- Dependency Injection fehlgeschlagen (`Depends()`)?
- CORS-Middleware Reihenfolge falsch?

**Docker / Container:**
- Service-Name im Compose-Netzwerk falsch referenziert?
- Volume-Mount überschreibt kompilierte Artefakte?
- Health-Check blockiert Startup-Reihenfolge?
- Port 0.0.0.0 vs. 127.0.0.1 (nur im Container erreichbar)?

**Datenbank (Postgres/SQLite/…):**
- Migration-Stand prüfen (welche Migrations sind gelaufen?)
- Connection-String in Container vs. lokal unterschiedlich?
- N+1 Query oder fehlendes Index bei Timeout?

## Schritt 3 — Ausgabe

Strukturierter Report:

```
## Fehler-Analyse: [kurzer Titel]

**Stack:** [erkannter Stack]
**Kategorie:** [Fehler-Typ]
**Konfidenz:** [hoch/mittel/niedrig]

### Root Cause (wahrscheinlichste Ursache)
[1-3 Sätze, was schief läuft und warum]

### Betroffene Dateien
- [Datei:Zeile] — [was dort falsch ist]

### Fix
[konkreter Fix mit Code-Snippet wenn möglich]

### Verifikation
[Wie prüft man, dass der Fix funktioniert hat?]

### Falls der Fix nicht hilft
[Nächste Hypothese + was dann zu prüfen ist]
```

## Regeln
- Keine Checklisten-Abarbeitung. Nur was für diesen Fehler relevant ist.
- Keine Fix-Varianten anbieten wenn eine klar dominiert — direkt empfehlen.
- Wenn der Fehler nicht eindeutig lokalisierbar: zwei gezielte Diagnose-Schritte vorschlagen,
  nicht alle möglichen Ursachen aufzählen.
- Automatisch fixen nur wenn der Nutzer es explizit verlangt.
