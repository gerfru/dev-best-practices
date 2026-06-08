# State Management — IaC

## Remote State Backends

| Backend | Provider | Locking | Empfehlung |
|---|---|---|---|
| S3 + DynamoDB | AWS | DynamoDB Table | Standard fuer AWS |
| GCS + Firestore | GCP | Native GCS | Standard fuer GCP |
| Azure Blob + Storage Lock | Azure | Lease-basiert | Standard fuer Azure |
| Terraform Cloud / HCP Terraform | HashiCorp | Native | Cloud-agnostisch, Collaboration-Features |
| GitLab Managed Terraform | GitLab | Native | Bei GitLab CI/CD |

**Niemals lokaler State in Prod.** Lokaler State: nur fuer lokale Entwicklung und Tests.

---

## State-Security

| Massnahme | Warum |
|---|---|
| Encryption at rest aktivieren | State kann Secrets enthalten (Passwoerter, Keys) |
| Encryption in transit (TLS) | State wird ueber Netzwerk uebertragen |
| Least Privilege Zugriff | Nur CI/CD Pipeline und Admins duerfen State lesen/schreiben |
| State-Locking | Verhindert parallele Applies (Race Conditions) |
| State-Backup | Versionierung im Backend aktivieren (S3 Versioning, GCS) |

---

## Workspace-Strategie

| Ansatz | Wann | Einschraenkung |
|---|---|---|
| **Workspace per Environment** | Gleicher Code, verschiedene Variablenwerte (dev/staging/prod) | Schlechte Isolation: ein Plan betrifft alle Envs |
| **Separate State-Pfade** | Verschiedene `backend` Konfigurationen pro Env | Mehr Komplexitaet, aber saubere Isolation |
| **Separate Repos** | Enterprise, strikte Isolation, verschiedene Teams pro Env | Hoechste Isolation, aber viel Overhead |

Empfehlung fuer die meisten Teams: **Separate State-Pfade** (z.B. `s3://bucket/envs/prod/terraform.tfstate`).

---

## State-Drift Workflow

```text
1. terraform plan          → zeigt Drift zwischen State und tatsaechlicher Infra
2. Entscheiden:
   ├─ Drift gewollt?       → terraform apply (State an Realitaet anpassen)
   └─ Drift ungewollt?     → manuelle Korrektur zuerst, dann apply
3. Root Cause: wer hat manuell geaendert? → Prozess verbessern
4. Drift-Detection automatisieren: plan im Schedule-Job, Alert bei Diff != 0
```

---

## Import vs. Neu Provisionieren

| Situation | Empfehlung |
|---|---|
| Bestehende Ressource soll unter IaC | `terraform import` — Ressource in State aufnehmen ohne Aenderung |
| Ressource nach manueller Loeschung neu | Neu provisionieren via `apply` |
| Migrationsprojekt: alles unter IaC bringen | Import-Strategie: eine Ressource nach der anderen, immer verifizieren |
