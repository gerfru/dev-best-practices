---
name: dev:design-ux
description: >
  Human-Centered UX Design skill grounded in the leading academic HCI curricula
  (CMU HCII, Stanford CS 247A/347, ETH, TU Wien, TU Graz) and the four canonical
  industry frameworks: Microsoft HAX 18 Guidelines (Amershi et al., CHI 2019),
  Google PAIR Guidebook (23 Patterns), CHI 2024 Generative AI Design Principles
  (IBM Research, 6 Principles), and Nielsen Norman Group AI Design.
  Use this skill whenever the user wants to design the UX/UI of a new product,
  feature, or AI-powered system — or when they ask "how should this feel to the
  user", "what's the right interaction model", "how do I handle AI outputs in the
  UI", "trust and transparency design", "onboarding for AI features",
  "how to avoid dark patterns / AI anti-patterns". Covers all product types:
  web apps, mobile, AI assistants, chatbots, dashboards, internal tools, voice UIs.
---

# UX Design (framework-based)

Turns a product or feature idea into well-reasoned UX decisions.
Standard: the four canonical frameworks (HAX · PAIR · CHI 2024 · NNG) plus
academic HCI grounding. No generic advice — every decision references a
guideline or principle.

---

## Core Philosophy

Good UX decisions are not a stylesheet bolted on at the end of the project. They are:

1. **User-centered**: user needs and mental models before interface decisions
2. **Contextual**: interaction model follows the task, not the technology
3. **Trust-building**: calibrated trust is an explicit design decision
4. **Explained**: every choice has a "why" the team understands and can defend
5. **Iterative**: revisit UX decisions as user behavior becomes visible

Especially for AI features: **The interface is the contract between the system
and the user.** A poorly communicated AI feature creates distrust or
dangerous over-reliance — both are UX failures.

---

## Design Workflow

### Phase 0 — Understand Context

Gather from the description or by reading existing files:

1. **What does the product / feature do?** (1–2 sentences)
2. **Who are the users?** (expertise, context, access method)
3. **What tasks need to be accomplished?** (primary user goals)
4. **Is AI / ML involved?** (recommendations, generation, classification, agents)
5. **What is the channel?** (web, mobile, voice, embedded, dashboard, chat)
6. **Are there accessibility requirements?** (legal: EU Accessibility Act / BFSG)
7. **Which platform design system?** (Material Design 3, Apple HIG, agnostic, custom) — determines color roles, elevation, shape, typography defaults

If something essential is missing: ask **once**, do not guess. Mark assumptions
explicitly as `[Assumption]`.

---

### Phase 0.5 — Establish Platform Design System (when visual design is part of the task)

Decide once, then apply consistently:

| Platform / Context | System | Core Principle |
|--------------------|--------|----------------|
| Android / Web (Google-style) | Material Design 3 | Color Roles, Tonal Elevation, Shape |
| iOS / macOS | Apple HIG | Clarity, Deference, Depth |
| Enterprise / B2B | IBM Carbon | Accessibility-first, Data-Dense Patterns |
| No context / custom system | Agnostic + Design Tokens | Full control |

References: m3.material.io · developer.apple.com/design/human-interface-guidelines · carbondesignsystem.com

Document this decision under "Decisions" in `design-ux.md`.
If no system is chosen: mark explicitly as `[Assumption: agnostic]`.

---

### Phase 1 — Choose Interaction Model

The interaction model determines everything that follows. Choose deliberately, not by default.

| Model | When appropriate | Risk |
|-------|-----------------|------|
| Classic GUI | Structured tasks, predictable inputs | No direct risk |
| Chat / Conversation | Exploratory, unstructured requests | Articulation barrier, empty input field is off-putting |
| Hybrid (GUI + Prompt) | AI features in structured products | Complexity; two mental models |
| Ambient / Proactive | AI intervenes without explicit request | HAX G3: wrong timing destroys trust |
| Voice | Hands-free scenarios, accessibility | No visual feedback; error correction is difficult |

**NNG rule:** Do not default to chat. Validate chat against real user needs.
If users have precise, structured tasks → GUI. If exploratory, language-based
tasks → Chat or Hybrid.

---

### Phase 2 — Mental Models & Onboarding

*Reference: PAIR Chapter 2 · CHI 2024 P2 · HAX G1–G2 · NNG ELIZA Effect*

AI systems are dynamic, not static. Users bring incorrect mental models
from classical software. Onboarding must explicitly correct this.

**Onboarding sequence (4 questions in this order):**

1. **What can it do?** — Show capabilities clearly, with examples (PAIR P3: "Benefit, not technology")
2. **What can it not do?** — State limitations explicitly before the first failure occurs (HAX G1/G2)
3. **How does it change?** — System learns / improves / changes; communicate this (HAX G14/G18)
4. **How can it be improved?** — Make feedback mechanisms visible (HAX G15/G16)

**Prevent the ELIZA effect (NNG):**
- Check anthropomorphic phrasing: "I understand you" → better "I interpret your request as…"
- Openly state limitations, do not hide them
- Show competence rather than human-likeness (NNG: "Prioritize smarts over sentience")

**Communicate generative variability (CHI 2024 P4):**
- When identical inputs produce variable outputs: show this explicitly (Google Gemini: Multiple Drafts)
- Do not present this as an error — explain it as a feature

---

### Phase 3 — Calibrate Trust

*Reference: HAX G1–G2, G10–G11 · PAIR P11–P13, Chapter 3 · CHI 2024 P3 · NNG*

**Calibrated trust** is the goal — neither blind trust nor distrust.

| Decision | Guideline | Concrete |
|----------|-----------|----------|
| Show confidence? | PAIR P11 | Decide based on user testing; not always helpful |
| Show explanations? | PAIR P12 | Decision-relevant, not exhaustive |
| Build in friction? | CHI 2024 P3 S3 | Multi-draft review forces critical evaluation |
| Show sources? | CHI 2024 P3 S2 | Source transparency for factual claims |
| Name the AI's role? | CHI 2024 P3 S4 | Partner / assistant / tool — define clearly |
| Formatting vs. accuracy | NNG | Heavy formatting inhibits critical evaluation |

**Risk-based automation (PAIR P14 · P17):**
- Low risk + high user trust → more automation
- High risk / critical decisions → more control and confirmation
- Introduce automation in phases: None → Suggestion → Execution (PAIR P17: "Automate in phases")

---

### Phase 4 — Feedback & User Control

*Reference: HAX G7–G9, G15–G17 · PAIR P15–P18 · CHI 2024 P5*

**Design the control hierarchy:**

```text
Global settings (HAX G17)
  └─ Session-level control (HAX G8: efficient dismissal)
       └─ Item-level feedback (HAX G15: granular feedback)
            └─ Direct correction (HAX G9: efficient error correction)
```

**Co-creation design (CHI 2024 P5):**
- Input assistance: show prompting tips, examples, parameter controls
- Co-editing: make generated outputs directly editable (Adobe Photoshop model)
- Domain controls: make domain-specific parameters visible (not just generic ones)

**Implicit vs. explicit feedback (PAIR P15, P20):**
- Implicit: click behavior, dwell time, what gets reused
- Explicit: thumbs up/down, structured forms, direct editing
- Both types need clear communication design about their effect (HAX G16)

---

### Phase 5 — Errors & Graceful Failure

*Reference: HAX G9–G11 · PAIR Chapter 6 · CHI 2024 P6 · NNG*

**Three error categories:**

| Type | Example | Design response |
|------|---------|-----------------|
| Scope error | Request outside capabilities | HAX G10: restrict conservatively, communicate clearly |
| Quality error | Output not good enough | CHI 2024 P6: make uncertainty visible; Edit/Regenerate |
| Trust error | User does not notice the error | NNG: build in friction; verification hints |

**Fallback design (PAIR P18):**
- When automation fails: seamless fallback to manual control
- No "Error 500" for AI failures — guide user to a manageable action
- Write error messages from the user's perspective (not technical)

**Communicate uncertainty (CHI 2024 P6 S1):**
- Disclaimers, confidence highlights, visual differentiation between certain/uncertain
- Show domain-specific quality metrics when available

---

### Phase 6 — Long-term Design

*Reference: HAX G12–G18*

| Guideline | Design implication |
|-----------|--------------------|
| G12: Recent interactions | Design session context and history access |
| G13: Learn from behavior | Make feedback loops visible; explain personalization |
| G14: Update cautiously | Communicate model updates gradually and transparently |
| G16: Consequences of actions | Make visible how user choices affect the system |
| G18: Notify about changes | Change log or in-app notifications for relevant changes |

---

### Phase 7 — Check Anti-Patterns

Before finalizing the design: explicitly check against this list.

| Anti-Pattern | Test | Solution |
|-------------|------|----------|
| Technology-first design | Is there a validated user problem? | Problem first, then AI |
| "Powered by AI" as value prop | Does the interface show concrete user benefit? | Show benefit, not tech |
| Chat solves everything | Is chat the right model for this task? | Validate the interaction model |
| Unscoped AI | Are capability boundaries clearly communicated? | Apply HAX G1/G2 |
| Prompts without help | Do users have support when formulating requests? | Examples + templates |
| Over-anthropomorphization | Does the language suggest false human-likeness? | Check phrasing |
| Heavy formatting over accuracy | Does formatting prevent critical evaluation? | Check the balance |
| No feedback path | Can users report and correct errors? | Implement HAX G9/G15 |
| Proactive at the wrong time | Does the system interrupt ongoing tasks? | HAX G3: timing |

---

## Output — Design File

Write the result to `./design-ux.md`:

```markdown
# UX Design: [Product / Feature Name]
Date: YYYY-MM-DD

## Context
[Product, users, channel, AI involvement: yes/no/how]

## Decisions
| Dimension | Decision | Rationale | Framework Reference |
|-----------|----------|-----------|---------------------|
| Platform Design System | … | … | m3.material.io / HIG / Carbon |
| Interaction model | … | … | NNG / PAIR P… |
| Mental model onboarding | … | … | HAX G1/G2, PAIR Ch.2 |
| Trust calibration | … | … | CHI 2024 P3, PAIR P11 |
| Feedback & control | … | … | HAX G7-G9, G15-G17 |
| Error handling | … | … | HAX G9-G11, CHI 2024 P6 |
| Long-term design | … | … | HAX G12-G18 |

## Anti-Pattern Check
| Anti-Pattern | Status | Measure |
|-------------|--------|---------|
| … | ✅ Ruled out / ⚠️ Risk / ❌ Present | … |

## Assumptions & Open Questions
- [Assumption]: …
- [to verify]: …

---
## UX Setup Todos
- [ ] Sketch onboarding flow (Phase 2)
- [ ] User-test confidence display (PAIR P11)
- [ ] Implement feedback mechanism (HAX G15)
- [ ] Anti-pattern review with team (Phase 7)

## Next Steps (prioritized)
1. …
```

---

## Interaction Patterns

### When the user says "just make it look nice"

Ask specifically: Nice for whom? In what context? With what goal?
"Nice" without a user goal is decorative, not UX. Redirect to task and user.

### When the user asks "should I use chat or GUI?"

Apply the NNG decision tree: task is precise + structured → GUI.
Task is exploratory + language-based + variable → Chat or Hybrid.
Never default to chat without validation.

### When AI features are being added to an existing product

Phase 2 (mental models) requires extra care: users have an existing model
of the product. The AI extension must be integrated into that model, not
thrown underneath it. HAX G18 (notify about changes) is mandatory.

### When the product uses generative AI (LLM, image generation, code)

Go through CHI 2024 P4–P6 fully: communicate variability, design co-creation,
plan imperfection handling. These three principles are GenAI-specific
and are not covered in classical UX frameworks.

### When accessibility is relevant

EU Accessibility Act / BFSG is legally mandatory. Semantic HTML,
heading hierarchy, alt texts, focus styles. AI-generated content needs
accessible output formats. axe-core + Lighthouse for automated checks.

---

## Framework Reference

Complete mapping of all design decisions to HAX Guidelines, PAIR Patterns,
CHI 2024 Principles, NNG, and academic courses: `references/framework-mapping.md`
