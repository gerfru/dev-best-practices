# State Management — IaC

## Remote State Backends

| Backend | Provider | Locking | Recommendation |
|---|---|---|---|
| S3 + DynamoDB | AWS | DynamoDB Table | Standard for AWS |
| GCS + Firestore | GCP | Native GCS | Standard for GCP |
| Azure Blob + Storage Lock | Azure | Lease-based | Standard for Azure |
| Terraform Cloud / HCP Terraform | HashiCorp | Native | Cloud-agnostic, collaboration features |
| GitLab Managed Terraform | GitLab | Native | For GitLab CI/CD |

**Never local state in prod.** Local state: only for local development and tests.

---

## State Security

| Measure | Why |
|---|---|
| Enable encryption at rest | State can contain secrets (passwords, keys) |
| Encryption in transit (TLS) | State is transmitted over the network |
| Least privilege access | Only CI/CD pipeline and admins may read/write state |
| State locking | Prevents parallel applies (race conditions) |
| State backup | Enable versioning in backend (S3 Versioning, GCS) |

---

## Workspace Strategy

| Approach | When | Limitation |
|---|---|---|
| **Workspace per environment** | Same code, different variable values (dev/staging/prod) | Poor isolation: one plan affects all envs |
| **Separate state paths** | Different `backend` configurations per env | More complexity, but clean isolation |
| **Separate repos** | Enterprise, strict isolation, different teams per env | Highest isolation, but much overhead |

Recommendation for most teams: **Separate state paths** (e.g. `s3://bucket/envs/prod/terraform.tfstate`).

---

## State Drift Workflow

```text
1. terraform plan          → shows drift between state and actual infra
2. Decide:
   ├─ Drift intentional?   → terraform apply (align state to reality)
   └─ Drift unintentional? → manual correction first, then apply
3. Root cause: who made manual changes? → improve process
4. Automate drift detection: plan in scheduled job, alert when diff != 0
```

---

## Import vs. Re-Provisioning

| Situation | Recommendation |
|---|---|
| Existing resource should be under IaC | `terraform import` — bring resource into state without change |
| Resource after manual deletion | Re-provision via `apply` |
| Migration project: bring everything under IaC | Import strategy: one resource at a time, always verify |
