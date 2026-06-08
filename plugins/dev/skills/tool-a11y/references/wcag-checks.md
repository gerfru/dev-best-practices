# WCAG 2.2 — Kritische Success Criteria

Fokus auf haeufigste Audit-Findings und alle 9 neuen WCAG 2.2 SC.
Vollstaendige Liste: w3.org/TR/WCAG22

## Perceivable (Wahrnehmbar)

| SC | Titel | Level | Test-Methode |
|---|---|---|---|
| 1.1.1 | Non-text Content (alt-Text) | A | axe-core + manuell |
| 1.3.1 | Info and Relationships (semantisches HTML) | A | axe-core + manuell |
| 1.3.4 | Orientation (kein erzwungenes Portrait/Landscape) | AA | Manuell |
| 1.4.1 | Use of Color (nicht nur Farbe als Info) | A | Manuell |
| 1.4.3 | Contrast Minimum (4.5:1 Text, 3:1 Large Text) | AA | axe-core |
| 1.4.4 | Resize Text 200% ohne Verlust | AA | Manuell |
| 1.4.10 | Reflow bei 320px (kein horizontales Scrollen) | AA | Manuell |
| 1.4.11 | Non-text Contrast 3:1 (UI-Komponenten, Icons) | AA | axe-core |
| 1.4.12 | Text Spacing (Zeilenabstand, Letter-Spacing anpassbar) | AA | Bookmarklet |

## Operable (Bedienbar)

| SC | Titel | Level | Test-Methode |
|---|---|---|---|
| 2.1.1 | Keyboard (alles per Tastatur bedienbar) | A | Manuell |
| 2.1.2 | No Keyboard Trap | A | Manuell |
| 2.4.1 | Bypass Blocks (Skip-Link zu Main Content) | A | Manuell |
| 2.4.3 | Focus Order (logische Tab-Reihenfolge) | A | Manuell |
| 2.4.4 | Link Purpose (aus Text erkennbar) | A | axe-core + manuell |
| 2.4.7 | Focus Visible (sichtbarer Fokus-Indikator) | AA | Manuell |
| **2.4.11** | **Focus Not Obscured Minimum (Fokus nicht verdeckt)** | **AA** | **Manuell — NEU 2.2** |
| **2.4.12** | **Focus Not Obscured Enhanced** | **AAA** | **Manuell — NEU 2.2** |
| **2.4.13** | **Focus Appearance (Kontrast + Groesse des Fokus-Indikators)** | **AAA** | **Manuell — NEU 2.2** |
| 2.5.3 | Label in Name (sichtbares Label im accessible Name) | A | axe-core |
| **2.5.7** | **Dragging Movements (Alternative zu Drag & Drop)** | **AA** | **Manuell — NEU 2.2** |
| **2.5.8** | **Target Size Minimum (24×24px Klickziel)** | **AA** | **Manuell — NEU 2.2** |

## Understandable (Verstaendlich)

| SC | Titel | Level | Test-Methode |
|---|---|---|---|
| 3.1.1 | Language of Page (lang-Attribut gesetzt) | A | axe-core |
| 3.2.1 | On Focus (kein unerwarteter Context-Change) | A | Manuell |
| 3.2.2 | On Input (kein unerwarteter Context-Change) | A | Manuell |
| **3.2.6** | **Consistent Help (Hilfe immer an gleicher Stelle)** | **A** | **Manuell — NEU 2.2** |
| 3.3.1 | Error Identification (Fehlermeldungen spezifisch) | A | Manuell |
| 3.3.2 | Labels or Instructions (Formularfelder beschriftet) | A | axe-core + manuell |
| **3.3.7** | **Redundant Entry (keine Doppeleingabe in gleichem Prozess)** | **A** | **Manuell — NEU 2.2** |
| **3.3.8** | **Accessible Authentication Minimum (kein Gedaechtnis-Test)** | **AA** | **Manuell — NEU 2.2** |
| **3.3.9** | **Accessible Authentication Enhanced** | **AAA** | **Manuell — NEU 2.2** |

## Robust

| SC | Titel | Level | Test-Methode |
|---|---|---|---|
| 4.1.2 | Name, Role, Value (ARIA korrekt) | A | axe-core |
| 4.1.3 | Status Messages (ARIA live regions) | AA | axe-core + manuell |

---

## Automatisierte Tests finden ~30% aller Issues

Die restlichen 70% erfordern manuelle Tests (Keyboard, Screen Reader).
axe-core und Lighthouse pruefen nur was algorithmisch pruefbar ist.
