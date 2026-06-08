---
name: design-iac
description: >
  Infrastructure as Code Design grounded in "Infrastructure as Code" (Kief Morris,
  O'Reilly 2021) und NTNU IIKG3005 (einziger dedizierter akademischer IaC-Kurs weltweit).
  Deckt IaC-Prinzipien (Immutable Infrastructure, Idempotency, Single Source of Truth),
  Modul-Design, State Management, Drift Detection, GitOps-Workflow und Testing ab.
  Use this skill whenever the user wants to design or improve Infrastructure as Code,
  set up Terraform/Pulumi/CDK, or establish a GitOps workflow.
  Trigger: "Infrastructure as Code einrichten", "Terraform aufbauen", "IaC Design",
  "Modul-Struktur fuer Terraform", "State Management", "GitOps einrichten",
  "Drift Detection", "IaC testen mit Terratest", "Cloud-Infrastruktur versionieren",
  "Immutable Infrastructure", "wir haben Config Drift", "IaC Best Practices".
  Deckt ab: IaC-Prinzipien, Modul-Design, State Management (Remote Backend, Locking),
  Drift Detection, GitOps-Workflow, Testing (Terratest, Static Analysis).
---

# Infrastructure as Code Design

Entwirft eine IaC-Architektur von Modul-Design bis GitOps-Workflow — grounded in
Kief Morris "Infrastructure as Code" und NTNU IIKG3005.

---

## Core Philosophy (Kief Morris)

> "Treating infrastructure as code means applying software engineering practices —
> version control, testing, code review — to infrastructure definitions."
> — Kief Morris, Infrastructure as Code (2021)

Immutable Infrastructure und Single Source of Truth eliminieren Config Drift.
GitOps macht jeden Infrastruktur-Zustand reproduzierbar, reviewbar und rollbackbar.

---

## Schritt 0 — Kontext klären

**Fragen:**
- Cloud-Provider: AWS / GCP / Azure / Multi-Cloud / On-Prem?
- IaC-Tool: Terraform / OpenTofu / Pulumi / CDK / Ansible?
- Team-Groesse und -Reife: IaC-Erfahrung vorhanden?
- Bestehendes Setup: manuell provisioniert / teilweise IaC / kein IaC?
- CI/CD: GitHub Actions / GitLab CI / Jenkins / Terraform Cloud?
- Compliance-Anforderungen: PCI-DSS, SOC2, ISO 27001?

---

## Schritt 1 — IaC-Prinzipien verankern

(→ `references/iac-patterns.md`)

**1a — Immutable Infrastructure pruefen**

Werden Server nach dem Provisionieren noch manuell geaendert?
→ Wenn ja: Snowflake Anti-Pattern — Plan fuer Immutability erstellen.

**1b — Single Source of Truth definieren**

- Wo lebt der IaC-Code? (Git-Repo-Struktur)
- Gibt es manuelle Aenderungen parallel? → stoppen
- Alles was Infra-Zustand definiert muss im Repo sein

**1c — Anti-Patterns identifizieren**

Checklist: Config Drift / Snowflake Server / Copy-Paste IaC / Monolithic Stack / lokaler State in Prod

---

## Schritt 2 — Modul-Design

**2a — Stack-Schichtung planen**

```text
foundation/   # VPC, DNS, IAM Basis, Security Groups
platform/     # Kubernetes, Datenbanken, Queues, Caches
services/     # Applikations-Infra (pro Service oder Team)
```

Jede Schicht = eigener State, eigener Apply-Zyklus.

**2b — Modul-Grenzen ziehen**

Pro Modul: Single Responsibility (ein klar abgegrenzter Concern).
Inputs/Outputs explizit definieren — keine versteckten Abhaengigkeiten.

**2c — Modul-Versionierung**

Modules per Git-Tag referenzieren:
```text
source = "git::https://github.com/org/infra-modules//network?ref=v2.3.0"
```
Kein `?ref=main` in Prod-Environments.

---

## Schritt 3 — State Management

(→ `references/state-management.md`)

**3a — Remote Backend waehlen**

AWS → S3 + DynamoDB. GCP → GCS. Azure → Blob Storage. Multi-Cloud → Terraform Cloud.
Niemals lokaler State in Staging oder Prod.

**3b — State-Sicherheit**

- Encryption at rest + in transit aktivieren
- Least Privilege: nur CI/CD Pipeline + Admins
- State-Locking aktivieren (verhindert parallele Applies)
- Versionierung im Backend (S3 Versioning, GCS Versioning)

**3c — Workspace-Strategie**

Empfehlung: Separate State-Pfade pro Environment:
```text
s3://infra-state/envs/dev/terraform.tfstate
s3://infra-state/envs/staging/terraform.tfstate
s3://infra-state/envs/prod/terraform.tfstate
```

---

## Schritt 4 — Drift Detection und Remediation

**4a — Drift erkennen**

`terraform plan` als Scheduled Job (taeglich) — Alert wenn Output != "No changes".
Tools: Driftctl, Terraform Cloud Drift Detection, AWS Config.

**4b — Drift klassifizieren** (→ `references/iac-patterns.md`)

Gewollter Drift (externe Aenderung beabsichtigt) vs. ungewollter Drift (manueller Eingriff).

**4c — Prozess-Fix**

Root Cause: Wer hat manuell geaendert und warum?
Losung: Break-Glass-Prozess fuer Notfaelle (erlaubt, aber dokumentiert und nachverfolgt).

---

## Schritt 5 — GitOps-Workflow

**5a — Branch-Strategie**

```text
feature/* → main: PR mit Plan-Output als Comment
main → staging: automatisch (nach PR-Merge)
staging → prod: manuelles Approval-Gate
```

**5b — Plan-Output im PR**

CI kommentiert `terraform plan` Diff in jeden PR.
Reviewer sehen exakt was sich aendert — kein Blind-Merge.

**5c — Apply-Strategie**

- Staging: automatisch nach Merge
- Prod: manuelles Approval (min. 1 Reviewer) + automatischer Apply
- Rollback: vorherigen Commit re-applyen (nicht `terraform destroy`)

---

## Schritt 6 — Testing

(→ `references/iac-patterns.md` fuer Drift-Tests)

**6a — Static Analysis**

- `terraform validate` — Syntaxfehler
- `terraform fmt --check` — Formatierung
- `tflint` — Best-Practice-Violations
- `checkov` / `tfsec` — Security Misconfigurations

**6b — Unit-Tests (Terratest)**

```go
// Beispiel: Terratest prueft ob S3-Bucket erstellt wurde
terraform.InitAndApply(t, terraformOptions)
bucketID := terraform.Output(t, terraformOptions, "bucket_id")
aws.AssertS3BucketExists(t, "us-east-1", bucketID)
```

**6c — Contract Tests**

Outputs eines Moduls gegen erwartete Struktur pruefen.
Stellt sicher dass Downstream-Module nicht brechen.

---

## Output — `iac-design.md`

```markdown
# IaC Design — [Projekt-Name]

## Stack-Schichtung
| Stack | Zweck | State-Pfad |
|---|---|---|
| foundation | VPC, IAM | s3://state/foundation/ |
| platform | K8s, DB | s3://state/platform/ |
| services | App-Infra | s3://state/services/ |

## Module
| Modul | Inputs | Outputs | Version |
|---|---|---|---|
| network | cidr, region | vpc_id, subnet_ids | v1.2.0 |

## State Backend
- Provider: [S3+DynamoDB / GCS / TF Cloud]
- Encryption: ja
- Locking: ja
- Workspace-Strategie: [separate Pfade / Workspaces]

## GitOps-Workflow
- Plan im PR: ja
- Apply Staging: automatisch nach Merge
- Apply Prod: manuelles Approval

## Testing
- Static: tflint + checkov
- Unit: Terratest
- Drift Detection: [taeglich / Terraform Cloud]
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → Kief Morris Kapitel + NTNU IIKG3005
- `references/iac-patterns.md` — Core Patterns vs. Anti-Patterns, Modul-Design, Drift-Klassifikation
- `references/state-management.md` — Remote Backends, Security, Workspace-Strategie, Import-Workflow
