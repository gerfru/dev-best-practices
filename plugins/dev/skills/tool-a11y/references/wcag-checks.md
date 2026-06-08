# WCAG 2.2 — Critical Success Criteria

Focus on most common audit findings and all 9 new WCAG 2.2 SC.
Complete list: w3.org/TR/WCAG22

## Perceivable

| SC | Title | Level | Test Method |
|---|---|---|---|
| 1.1.1 | Non-text Content (alt text) | A | axe-core + manual |
| 1.3.1 | Info and Relationships (semantic HTML) | A | axe-core + manual |
| 1.3.4 | Orientation (no forced portrait/landscape) | AA | Manual |
| 1.4.1 | Use of Color (not color alone as info) | A | Manual |
| 1.4.3 | Contrast Minimum (4.5:1 text, 3:1 large text) | AA | axe-core |
| 1.4.4 | Resize Text 200% without loss | AA | Manual |
| 1.4.10 | Reflow at 320px (no horizontal scrolling) | AA | Manual |
| 1.4.11 | Non-text Contrast 3:1 (UI components, icons) | AA | axe-core |
| 1.4.12 | Text Spacing (line height, letter-spacing adjustable) | AA | Bookmarklet |

## Operable

| SC | Title | Level | Test Method |
|---|---|---|---|
| 2.1.1 | Keyboard (everything operable by keyboard) | A | Manual |
| 2.1.2 | No Keyboard Trap | A | Manual |
| 2.4.1 | Bypass Blocks (skip link to main content) | A | Manual |
| 2.4.3 | Focus Order (logical tab order) | A | Manual |
| 2.4.4 | Link Purpose (determinable from text) | A | axe-core + manual |
| 2.4.7 | Focus Visible (visible focus indicator) | AA | Manual |
| **2.4.11** | **Focus Not Obscured Minimum (focus not obscured)** | **AA** | **Manual — NEW 2.2** |
| **2.4.12** | **Focus Not Obscured Enhanced** | **AAA** | **Manual — NEW 2.2** |
| **2.4.13** | **Focus Appearance (contrast + size of focus indicator)** | **AAA** | **Manual — NEW 2.2** |
| 2.5.3 | Label in Name (visible label in accessible name) | A | axe-core |
| **2.5.7** | **Dragging Movements (alternative to drag & drop)** | **AA** | **Manual — NEW 2.2** |
| **2.5.8** | **Target Size Minimum (24×24px click target)** | **AA** | **Manual — NEW 2.2** |

## Understandable

| SC | Title | Level | Test Method |
|---|---|---|---|
| 3.1.1 | Language of Page (lang attribute set) | A | axe-core |
| 3.2.1 | On Focus (no unexpected context change) | A | Manual |
| 3.2.2 | On Input (no unexpected context change) | A | Manual |
| **3.2.6** | **Consistent Help (help always in same location)** | **A** | **Manual — NEW 2.2** |
| 3.3.1 | Error Identification (specific error messages) | A | Manual |
| 3.3.2 | Labels or Instructions (form fields labeled) | A | axe-core + manual |
| **3.3.7** | **Redundant Entry (no duplicate entry in same process)** | **A** | **Manual — NEW 2.2** |
| **3.3.8** | **Accessible Authentication Minimum (no memory test)** | **AA** | **Manual — NEW 2.2** |
| **3.3.9** | **Accessible Authentication Enhanced** | **AAA** | **Manual — NEW 2.2** |

## Robust

| SC | Title | Level | Test Method |
|---|---|---|---|
| 4.1.2 | Name, Role, Value (ARIA correct) | A | axe-core |
| 4.1.3 | Status Messages (ARIA live regions) | AA | axe-core + manual |

---

## Automated Tests Find ~30% of All Issues

The remaining 70% require manual testing (keyboard, screen reader).
axe-core and Lighthouse only check what is algorithmically verifiable.
