# IA Artifact Templates

Concrete templates for every artifact in the structural design chain.
Source: Garrett, "The Elements of User Experience" (5-plane model) ·
Rosenfeld/Morville/Arango, "Information Architecture for the Web and Beyond".

---

## 1. Problem Brief

```text
Product / Feature:
Primary Users:
Primary Goal:
Main Tasks:
Business Constraints:
Technical Constraints:
Known Problems:
Open Questions:
Success Criteria:
```

Separate strictly: confirmed requirements vs. assumptions vs. open questions.
No UI solutions at this stage.

---

## 2. User / Role Matrix

| Role | Main Goal | Frequent Tasks | Required Information | Permissions |
|---|---|---|---|---|
| Admin | ... | ... | ... | Full |
| Manager | ... | ... | ... | Limited |
| User | ... | ... | ... | Restricted |

Purpose: reveals early whether a single interface can serve all roles at all.

---

## 3. Task Inventory

```text
Task: Find a customer
Actor: Sales rep
Frequency: Very high
Criticality: High
Starting point: Global navigation
Required data: Name, ID, company
Expected completion: < 10 seconds
```

Rank tasks by: Frequency · Criticality · Complexity · Business Value · Error Risk.

---

## 4. Domain / Entity Model

| Entity | Key Attributes | Relationships | Important Actions |
|---|---|---|---|
| Customer | Name, ID, Status | has many Projects | Edit, Archive |
| Project | Owner, Deadline | belongs to Customer, has Tasks | Close |
| Task | Assignee, Status | belongs to Project | Complete |

One of the most important artifacts for complex business software.

---

## 5. Content Inventory

```text
Project Detail
  Identity: Project name, Customer, Project ID
  Status: Current status, Health, Deadline
  Responsibility: Owner, Team
  Operational Data: Tasks, Risks, Milestones
  Supporting Content: Documents, Comments, Activity history
```

More granular than the entity model — every piece of content that must
actually be displayed somewhere, not just the objects that hold it.

---

## 6. Information Hierarchy

```text
LEVEL 1 - Always visible: name, status, owner, deadline
LEVEL 2 - Primary workspace: tasks, risks, milestones
LEVEL 3 - Secondary: documents, comments, history
LEVEL 4 - On demand: technical metadata, audit info, IDs
```

Prevents AI-generated layouts from rendering everything with equal visual weight.

---

## 7. Navigation Map

```text
Application
  Home
  Projects
    Project List
    Project Detail
      Overview / Tasks / Risks / Documents
  Customers
  Reports
  Settings
```

Classify every nav item as: Global · Local · Contextual · Utility.

---

## 8. Screen Inventory

| Screen | Purpose | Primary Task | Entry Point |
|---|---|---|---|
| Project List | Find projects | Search/select | Navigation |
| Project Detail | Work on a project | Review/edit | Project list |
| Settings | Configure | Administration | Global nav |

Guards against unnecessary screens and dialogs before any wireframing starts.

---

## 9. User Flow

```text
Goal: Change project owner

Project List -> Project Detail -> Current Owner -> Change Owner
  -> Select Person -> Confirm -> Updated Project
```

Document explicitly: Entry Point · Happy Path · Alternative Path · Error Path · Exit State.

---

## 10. Interaction Pattern Decision

```text
Problem: User needs to inspect many projects and rapidly compare details.

Candidates:
1. Separate list + detail page
2. Master-detail split view
3. Expandable rows

Decision: Master-detail split view
Reason: Frequent switching between projects makes full-page navigation inefficient.
Trade-off: Requires more horizontal screen space.
```

Prevents arbitrary GUI decisions — every pattern choice is traceable to a reason.

---

## 11. UX Decision Log

```text
DEC-014
Decision: Use tabs inside Project Detail.
Reason: Overview, Tasks and Risks are distinct but equally important contexts.
Rejected: Long single-page detail view.
Reason for rejection: Excessive scrolling for task-heavy users.
```

Rule: do not contradict a prior decision without explicitly stating the reason for changing it.

---

## 12. Low-Fidelity Wireframe

```text
+-----------------------------------------------+
| Search                              User      |
+-------------+-----------------------------------+
| Projects    | Project Alpha                    |
| Customers   | Status  Owner  Deadline           |
| Reports     +-----------------------------------+
|             | Overview Tasks Risks Docs         |
|             +-----------------------------------+
|             | Main workspace                    |
+-------------+-----------------------------------+
```

No color, shadow, radius, illustration, or branding at this stage.

---

## 13. Component Inventory

```text
Navigation: Global Sidebar, Local Tabs, Breadcrumb
Data Display: Table, Detail Header, Definition List, Activity Feed
Input: Search, Filter, Select, Text Field
Actions: Primary Button, Inline Action, Context Menu
```

Use to check whether unnecessary special-purpose components are being invented.

---

## 14. State Matrix

| State | Expected UI |
|---|---|
| Loading | Skeleton / progress |
| Empty | Explanation + relevant action |
| Error | Error + recovery action |
| Permission denied | Explanation |
| Partial data | Visible warning |
| Success | Updated state |
| Offline | Appropriate status |

Element-level states to also cover: Default · Hover · Focus · Selected · Disabled · Read-only · Validation Error.

---

## 15. Permission Matrix

| Action | Admin | Manager | User |
|---|---:|---:|---:|
| View project | Yes | Yes | Assigned only |
| Edit project | Yes | Yes | No |
| Delete project | Yes | No | No |
| Change owner | Yes | Yes | No |

Drives which actions are visible vs. hidden vs. disabled in the UI.

---

## 16. Data Density Specification

```text
Target environment: Desktop application
Usage: Daily professional use
Information density: Medium-high
Typical viewport: 1440 x 900
Expected visible rows: 15-25
Primary interaction: Mouse + keyboard
Large touch targets: Not required
Whitespace: Use for hierarchy, not decoration.
```

---

## 17. Visual Design Constraints

```text
Typography: Functional, restrained hierarchy
Spacing: Compact
Containers: Only where semantically necessary
Radius: Small and consistent
Shadows: Rare
Color: Primarily for hierarchy, status and actions
Icons: Only for recognizable functions
Animation: Only to communicate state or continuity
```

Set once, before touching visual design — see `anti-ai-visual-checklist.md` for what
to actively avoid.

---

## 18. Requirement -> UI Traceability

| Requirement | User Task | Screen | UI Element |
|---|---|---|---|
| User must find project | Search | Project List | Search field |
| User must change owner | Edit project | Detail | Owner field |
| User must inspect risk | Review risk | Risks | Risk list |

Any UI element with no row in this table has no traceable reason to exist.
