# Bentley Rules fuer Performance-Optimierung

Quelle: MIT 6.172 Lecture 2. Aus Jon Bentley "Writing Efficient Programs" (1982),
destilliert von Charles Leiserson und Julian Shun.

## Datenstrukturen

| Regel | Technik | Beispiel |
|---|---|---|
| Augmentation | Zusaetzliche Info in Struktur cachen | Summe in BST-Knoten mitfuehren |
| Precomputing | Teure Ergebnisse vorab berechnen | Lookup-Tabelle fuer Sinus-Werte |
| Compile-Time Init | Konstanten zur Compile-Zeit | `constexpr`, statische Arrays |
| Caching | Haeufige Ergebnisse zwischenspeichern | Memoization, LRU-Cache |
| Lazy Evaluation | Erst berechnen wenn noetig | Iteratoren, Generator-Patterns |
| Coarsening Recursion | Basisfall frueher abbrechen | n < 16 → Insertion Sort statt Quicksort |

## Logik

| Regel | Technik | Beispiel |
|---|---|---|
| Constant Folding | Konstante Subexpressions vorab | `2 * 3.14159` zur Compile-Zeit |
| Common Subexpression | Gleiche Berechnung nur einmal | `len(arr)` aus dem Loop heraus |
| Algebraic Identities | Aequivalente guenstigere Op | Division durch 2 → Right-Shift |
| Short-Circuit Evaluation | Guenstige Bedingung zuerst | `if cheap_check && expensive_check` |
| Loop-Invariant Hoisting | Konstantes aus Loop | Array-Laenge vor Loop berechnen |
| Tail-Recursion | Tail Calls → Iteration | Kein Stack-Wachstum |

## Loops

| Regel | Technik | Wann |
|---|---|---|
| Hoisting | Invariante Berechnung vor Loop | Jede nicht-abhaengige Berechnung |
| Sentinels | Grenzwert als letztes Element | Erspart Bounds-Check |
| Unrolling | Mehrere Iter. pro Loop-Body | Wenn Branch-Prediction kostet |
| Fusion | Zwei Loops zu einem | Wenn beide ueber gleiche Daten |
| Early Exit | Break/Return bei erstem Fund | Search, Validation |

## Funktionen

| Regel | Technik | Wann |
|---|---|---|
| Inlining | Kleine Funktion direkt einbetten | Call-Overhead messbar |
| Tail-Call Optimization | Letzter Call ohne neuen Frame | Rekursive Funktionen |

## Memory / Cache

| Regel | Technik | Beispiel |
|---|---|---|
| Cache-Friendly Access | Row-major fuer 2D Arrays | `arr[i][j]` statt `arr[j][i]` |
| Struct Packing | Padding minimieren | Grosse Felder zuerst |
| Data Alignment | SIMD / Cache-Line Alignment | `__attribute__((aligned(64)))` |
| False Sharing vermeiden | Shared Cache-Lines zwischen Threads | Padding zwischen Thread-Daten |

---

## Warnung: Premature Optimization

> "The real problem is that programmers have spent far too much time worrying about
> efficiency in the wrong places and at the wrong times."
> — Donald Knuth

**Vorgehen immer:** Messen → Bottleneck identifizieren → Optimieren → Messen.
Nie ohne Profiling-Daten optimieren.
