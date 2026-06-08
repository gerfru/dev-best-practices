# Bentley Rules for Performance Optimization

Source: MIT 6.172 Lecture 2. From Jon Bentley "Writing Efficient Programs" (1982),
distilled by Charles Leiserson and Julian Shun.

## Data Structures

| Rule | Technique | Example |
|---|---|---|
| Augmentation | Cache additional info in structure | Maintain sum in BST node |
| Precomputing | Compute expensive results in advance | Lookup table for sine values |
| Compile-Time Init | Constants at compile time | `constexpr`, static arrays |
| Caching | Store frequent results | Memoization, LRU cache |
| Lazy Evaluation | Compute only when needed | Iterators, generator patterns |
| Coarsening Recursion | Exit base case earlier | n < 16 → insertion sort instead of quicksort |

## Logic

| Rule | Technique | Example |
|---|---|---|
| Constant Folding | Pre-compute constant subexpressions | `2 * 3.14159` at compile time |
| Common Subexpression | Same calculation only once | `len(arr)` hoisted out of loop |
| Algebraic Identities | Equivalent cheaper operation | Division by 2 → right-shift |
| Short-Circuit Evaluation | Cheap condition first | `if cheap_check && expensive_check` |
| Loop-Invariant Hoisting | Constants out of loop | Compute array length before loop |
| Tail-Recursion | Tail calls → iteration | No stack growth |

## Loops

| Rule | Technique | When |
|---|---|---|
| Hoisting | Invariant computation before loop | Any non-dependent computation |
| Sentinels | Boundary value as last element | Saves bounds check |
| Unrolling | Multiple iterations per loop body | When branch prediction costs |
| Fusion | Two loops into one | When both iterate over same data |
| Early Exit | Break/return on first find | Search, validation |

## Functions

| Rule | Technique | When |
|---|---|---|
| Inlining | Embed small function directly | Call overhead measurable |
| Tail-Call Optimization | Last call without new frame | Recursive functions |

## Memory / Cache

| Rule | Technique | Example |
|---|---|---|
| Cache-Friendly Access | Row-major for 2D arrays | `arr[i][j]` instead of `arr[j][i]` |
| Struct Packing | Minimize padding | Large fields first |
| Data Alignment | SIMD / cache-line alignment | `__attribute__((aligned(64)))` |
| Avoid False Sharing | Shared cache lines between threads | Padding between thread data |

---

## Warning: Premature Optimization

> "The real problem is that programmers have spent far too much time worrying about
> efficiency in the wrong places and at the wrong times."
> — Donald Knuth

**Always proceed:** Measure → identify bottleneck → optimize → measure.
Never optimize without profiling data.
