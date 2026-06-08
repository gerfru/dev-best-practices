---
name: review-app
description: Vollständige End-to-End-Evaluierung einer App/Codebase - misst die Codebase gegen die Dev-Best-Practices-Regeln dieses Repos (essential/app/github/architecture). Achsen: Architektur (12-Factor), Security (OWASP ASVS 5.0/Top 10), CI-CD-Delivery (DORA), Code-Qualität, Tests, Observability. Use this skill whenever the user wants to audit, evaluate, review or assess an entire app or codebase, check production-/release-readiness, find technical debt, or do a security/architecture review. Trigger auch bei "evaluiere/auditiere/reviewe meine App", "ist meine App release-fertig", "Security-Review", "Architektur-Check" - selbst wenn nur eine einzelne Achse genannt wird. Wenn du Architektur ODER Security reviewen willst: nimm diesen Skill — er deckt beides ab. review-arch und review-secure sind Tiefenbohrer für den jeweiligen Fokus, review-app ist der vollständige Überblick.
---

# App Evaluation (repo-integriert)

Bewertet eine Ziel-Codebase gegen die Regeln dieses Dev-Best-Practices-Repos.
SOLL = die Regel-Files. IST = die Codebase. Befunde zitieren die verletzte Regel.

## Schritt 0 - Maßstab & Kontext laden

**Auto-Discovery (nie raten — lesen):**

| Was lesen | Ableitung |
|---|---|
| `package.json` | Sprache (TS/JS), Framework (Next.js/Express/NestJS/…), Test-Tool |
| `pyproject.toml` / `requirements.txt` | Python, Framework (FastAPI/Django/Flask), Package-Manager (uv/pip) |
| `go.mod` / `Cargo.toml` | Go / Rust |
| `Dockerfile` / `docker-compose.yml` | Container-Kontext, Services, Netzwerk |
| `.github/workflows/*.yml` | CI-Pipeline vorhanden, welche Steps |
| `CLAUDE.md` des Projekts | Dokumentierte Ausnahmen, bekannte Einschränkungen |
| Lock-Files (`pnpm-lock.yaml`, `uv.lock`, `package-lock.json`) | Tatsächlich verwendete Versionen |

**Aus Discovery ableiten (nicht nachfragen):**
- **Team-Größe:** Solo wenn kein Team-Kontext in `CLAUDE.md` → ASVS L1 Default
- **ASVS-Level:** L1 für Solo/Prototyp, L2 wenn Auth/Payment/sensible Daten erkennbar, L3 nur wenn explizit
- **Compliance:** DSGVO wenn EU-Nutzer in Beschreibung oder Datenschutz-Konzept vorhanden
- **Deployment-Ziel:** aus Dockerfile/CI ableiten (Container, Serverless, klassisch)

Nur nachfragen wenn Discovery keine eindeutige Antwort liefert (z.B. kein einziges Config-File vorhanden).
Nenne dem Nutzer die erkannten Werte kompakt: `Stack: Next.js 14 + TypeScript | DB: Postgres | CI: GitHub Actions | ASVS: L2`.

1. Bestimme die **Regelquelle** in dieser Reihenfolge:
   a) Regel-Files dieses Repos, falls erreichbar (`claude/essential-rules.md`,
      `claude/app-rules.md`, `claude/github-rules.md`, `claude/architecture-rules.md`;
      Tiefe bei Bedarf aus `reference/*.md`).
   b) sonst die `CLAUDE.md` des Ziel-Projekts (enthält oft die kopierten Essential-Rules).
   c) sonst Default-Standards (12-Factor, ASVS L2, DORA).
   Nenne dem Nutzer, welche Quelle aktiv ist.
2. Dokumentierte **Ausnahmen** aus `CLAUDE.md`/`REVIEW.md` übernehmen (z.B. absichtlich
   öffentliche Routes), damit Re-Runs konsistent bleiben.

## Schritt 1 - Plan zuerst
Skizziere kurz, welche sechs Subagenten mit welchem Scope laufen, welche Regelquelle
gilt und welche Tools fehlen (z.B. keine CI-Historie -> DORA nur Schätzung). Erst nach
kurzer Bestätigung ausführen.

## Schritt 2 - Sechs Subagenten PARALLEL
Alle sechs als Task-Subagenten in EINER Nachricht starten. Jeder gibt eine
**komprimierte** Befundliste zurück (keine Roh-Dumps), Hauptkontext bleibt sauber.

Jeder Befund:
`Titel · Datei:Zeile · Severity (Critical/High/Medium/Low) · Confidence (1-10) ·
verletzte Regel (Datei -> Section) · Fix · Aufwand (S<30min / M<2h / L>2h)`.

### Agent 1 - Architektur & 12-Factor
Maßstab: `architecture-rules.md` (+ `reference/architecture-best-practices.md`).
Prüfe: Feature-basierte Struktur, Schichtung (Routes->Service->Data Access),
Monolith-First, die 12 Faktoren (Config in Env, stateless, Logs auf Stdout, Port
Binding, Disposability), Docker-Architektur (127.0.0.1-Bind, Health Checks, Limits).

### Agent 2 - Security (ASVS 5.0 + Top 10)
Maßstab: `app-rules.md` Security-Sections (+ `reference/app-best-practices.md`).
Prüfe gegen ZIEL-ASVS-LEVEL: Security Headers (CSP/HSTS/…), Auth an 3 Schichten
(v.a. Data Access Layer), Input-Validierung (Zod/Pydantic), Prepared Statements,
DOM-XSS, Secrets-Handling, Cookie-Flags, CORS, File-Uploads, PostgreSQL-Hardening.
Tooling-Soll: gitleaks, bandit/ruff-S, semgrep, pip-audit, trivy.
Falls die offizielle `/security-review`-Komponente installiert ist, darf dieser Agent
sie nutzen statt zu duplizieren.
**False-Positive-Filter:** nur Confidence >= 7. Fehlende UUID-Validierung,
Resource-Leaks und Env-Var-abhängige Angriffe gelten NICHT als Schwachstelle.
Fehlende Audit-Logs → als ⚪ COMPLIANCE melden (ISO 27001 A.8.15 / GDPR Art. 32),
nicht als Security HIGH/CRITICAL.

### Agent 3 - Code-Qualität
Default-Schwellwerte (anpassbar, gehören perspektivisch in ein eigenes Regel-File):
Komplexität/Funktion Warnung >10 / Fail >20; Funktion >50 Zeilen; Datei >400 Zeilen;
Duplikation >3 %; Verschachtelung >4. Plus Naming, toter Code, fehlende Typisierung.

### Agent 4 - Tests & Zuverlässigkeit
Maßstab: `architecture-rules.md` (Testing-Strategie) + `github-rules.md` (Testing).
Test-Pyramide einschätzen; Coverage messen falls Tooling da (Soll: 70-80 % Lines,
kritische Pfade ~100 %). Ungetestete kritische Pfade (Auth, Payment, Datenmutationen)
explizit auflisten. Flaky/Skip/Smoke-only markieren.

### Agent 5 - CI/CD & Delivery (DORA)
Maßstab: `github-rules.md` (Pipeline, Branch Protection, Scanning).
Prüfe: Build/Lint/Type-Check/Test/gitleaks pro PR? semgrep+trivy mit exit-code 1?
Branch Protection auf main? Renovate? Deployment reproduzierbar + Rollback?
Lokalisiere die DORA-Hebel (Deployment Frequency, Lead Time for Changes,
Change Failure Rate, Failed Deployment Recovery Time). **Ehrlich kennzeichnen,**
welche Werte aus CI-Historie echt messbar sind und welche nur geschätzt.

### Agent 6 - Observability & Betrieb (Bash erlaubt)
Maßstab: `app-rules.md` (Logging/Monitoring/Observability) + `reference/`.
Prüfe: strukturiertes JSON-Logging (Pino/structlog), keine Secrets in Logs, Sentry,
Uptime, vier goldene Signale, Health/Ready-Endpoints, OpenTelemetry-Bereitschaft.
Dependency-Audit-CLI ausführen (`npm audit`/`pip-audit`) und zusammenfassen.
Container-Hygiene falls Dockerfile (non-root, Digest-Pin, Multi-Stage, `--check`).

## Schritt 3 - Konsolidieren & Report
1. Alle Befunde zu EINER nach Severity sortierten Liste mergen; Security <7 verwerfen.
2. Pro Achse eine Ampel (gruen/gelb/rot) + ein Satz Begründung.
3. Fix-Reihenfolge: geteilte Utilities/Security zuerst, dann Refactors, dann Tests, dann Kosmetik.
4. Schreibe Report nach `./review-app-report.md` mit Tabelle:
   `Achse | Ampel | #Critical | #High | wichtigste verletzte Regel`.

## Regeln
- Keine spekulativen Befunde. Nur mit Datei:Zeile-Bezug oder klar belegbarer Lücke.
  Unsicheres als "[zu verifizieren]" kennzeichnen.
- Jeder Befund nennt die konkrete verletzte Regel (Datei -> Section), nicht nur ein generisches Prinzip.
- **Nichts automatisch fixen.** Erst Report, dann auf Nachfrage gezielt umsetzen.
- Verifikation vor "fertig": Würde ein Staff-Engineer diesen Report freigeben?
- Neue bewusste Ausnahmen, die im Lauf auftauchen, der `CLAUDE.md` des Ziel-Projekts vorschlagen.

## Report Footer

Jeder generierte Report endet mit:

```markdown
---
*Erstellt mit KI-Unterstützung (Claude Code + dev-best-practices Plugin).
Findings sind zu verifizieren — kein Ersatz für manuelle Penetrationstests.*
```
