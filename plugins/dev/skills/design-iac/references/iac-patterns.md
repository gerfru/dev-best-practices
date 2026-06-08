# IaC Patterns und Anti-Patterns

Quelle: Kief Morris "Infrastructure as Code", O'Reilly 2021.

## Core Patterns

| Pattern | Beschreibung | Anti-Pattern |
|---|---|---|
| **Immutable Infrastructure** | Infra-Ressourcen nie aendern — immer neu provisionieren | Mutable: Server mit SSH patchen (Config Drift) |
| **Dynamic Infrastructure** | Ressourcen per API erzeugen/loeschen | Static: manuelles Setup, Snowflake Server |
| **Single Source of Truth** | Ein Repo definiert Soll-Zustand — kein manuelles Eingreifen | IaC + parallele manuelle Aenderungen |
| **Idempotent Apply** | Mehrfaches Apply → immer gleicher Zustand | Scripts mit Seiteneffekten bei Re-Run |
| **Small Focused Stacks** | Ein Stack pro Concern (Network / Compute / App) | Monolithic Stack (alles in einem) |
| **Composable Modules** | Module = wiederverwendbare Bausteine mit klaren Inputs/Outputs | Copy-Paste IaC |
| **GitOps** | Git = Single Source of Truth, Aenderungen nur per PR | Direkte CLI-Aenderungen in Prod |

**Snowflake Anti-Pattern:** Jeder Server wurde durch manuelle Aenderungen einzigartig — nicht reproduzierbar, nicht skalierbar, nicht loeschbar ohne Angst.

---

## Modul-Design Prinzipien

| Prinzip | Beschreibung |
|---|---|
| Single Responsibility | Ein Modul = ein klar abgegrenzter Concern |
| Stabile Interfaces | Input-Variablen und Outputs aendern sich selten |
| Keine versteckten Abhaengigkeiten | Alles was ein Modul braucht, kommt als Input |
| Versionierung | Module per Git-Tag versionieren (kein `?ref=main` in Prod) |
| Minimale Outputs | Nur was Downstream-Module wirklich brauchen |

---

## Stack-Schichtung (empfohlen)

```text
foundation/     # VPC, DNS, Security Groups, IAM Basis
platform/       # Kubernetes, Datenbanken, Message Queues
services/       # Applikations-Infrastruktur (pro Service/Team)
```

Jede Schicht hat eigenen State. Services-Schicht referenziert Platform-Outputs via Remote State Read.

---

## Drift-Klassifikation

| Typ | Ursache | Massnahme |
|---|---|---|
| Config Drift | Manuelle Aenderung nach Apply | `terraform plan` zeigt Diff, dann Apply |
| Version Drift | Modul-Version in einer Env zu alt | Update + Apply in allen Envs |
| Secret Drift | Secrets direkt geaendert, nicht per IaC | Secrets in Secrets-Manager, Referenz in IaC |
| Resource Drift | Ressource manuell geloescht | Import oder neu provisionieren |
