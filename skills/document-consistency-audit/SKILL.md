---
name: document-consistency-audit
description: >
  Systematic consistency audit across multi-file documents (thesis, report,
  book, docs). Nine domains: terminology, formatting (\textit \textbf dashes
  quotes), tone and voice, chapter structure, figures and tables, citations
  (\cite \citep \citet), narrative flow, math notation, figure size and
  style. Trigger on: inconsistency, terminology cleanup, formatting check,
  style standardisation, tone mismatch, structure review, British vs
  American English, math notation issues, figure sizing. Also trigger for:
  "supervisor said it's inconsistent", "standardise my document", "audit my
  thesis", "fix my formatting", "make my document consistent". Works with
  LaTeX, Markdown, plain text, reST. Even for single-domain requests,
  suggest full audit since inconsistencies cluster.
---

# Document Consistency Audit

## Overview

This skill performs a systematic, multi-phase consistency audit across a multi-file document. It covers nine audit domains, each with its own detailed checklist in the `references/` directory. The audit follows a strict phase sequence with user decision points between phases. No fixes are applied without explicit user approval.

### Audit Domains

| # | Domain | What it checks | Reference file |
|---|--------|---------------|----------------|
| 1 | **Terminology** | Same concept called different names, dangerous semantic conflicts, abbreviation discipline, spelling convention (British/American) | `references/terminology.md` |
| 2 | **Formatting & Styling** | Emphasis commands (`\textit`, `\textbf`, `\emph`, `\texttt`), quotation marks (`` `` '' `` vs `"`), dashes (em/en/hyphen), delimiters (`;` `/` `:`), whitespace, number formatting | `references/formatting.md` |
| 3 | **Tone & Voice** | Active vs passive, person (I/we/passive), tense per chapter type, academic vs informal vs instructional register, hedging consistency | `references/tone-voice.md` |
| 4 | **Chapter Structure** | Opening/closing patterns, section depth, orphan subsections, self-containment, section naming, list conventions | `references/structure.md` |
| 5 | **Figures & Tables** | Float environments, placement specifiers, caption style, cross-referencing (`Figure` vs `Fig.`), orphan floats, `\subfloat` vs `\subfigure` | `references/figures-tables.md` |
| 6 | **Citations & References** | `\cite` vs `\citep` vs `\citet`, citation placement relative to punctuation, footnote usage, citation density, bibliography keys | `references/citations.md` |
| 7 | **Narrative & Story** | Red thread traceability, claim consistency across chapters, forward reference fulfilment, intro-conclusion mirror, parallel structure | `references/narrative.md` |
| 8 | **Mathematical Notation** | Symbol definitions, equation environments, operator formatting, notation reuse, font consistency in math mode, equation numbering discipline | `references/math-notation.md` |
| 9 | **Figure Size & Visual Style** | Width specifications, aspect ratios, colour palettes, font sizes within figures, resolution, border/frame style, visual consistency across figure types | `references/figure-style.md` |

---

## Before You Start

### Step 0.1 — Gather project context

Ask the user (or extract from `CLAUDE.md` / project files):

1. **Document type:** Thesis, book, report, technical documentation, other?
2. **File locations:** Where are the document files? Discover with `find`.
3. **File format:** LaTeX, Markdown, plain text, other?
4. **Language convention:** British English, American English, or other? Check config files (e.g., `babel` in LaTeX).
5. **Style guide:** Does the user have an explicit style guide, template, or supervisor expectations document?
6. **Known problems:** Any inconsistencies the user already knows about?
7. **Protected zones:** Content that must NOT be modified (code blocks, `\label{}`, URLs, etc.)
8. **Dangerous terms:** Terms where using the wrong variant changes meaning, not just style.
9. **Math conventions:** Does the document use mathematical notation? Which packages (`amsmath`, `mathtools`, `unicode-math`)? Any notation glossary?
10. **Figure production method:** Are figures produced by code (matplotlib, R, tikz), external tools (draw.io, Lucidchart, Figma), screenshots, or mixed? This affects what can be standardised.

### Step 0.2 — Determine audit scope

Ask the user which domains to audit. Default: all nine. The user may choose a subset. If the document has no math, skip Domain 8. If all figures are screenshots with no control over styling, note Domain 9 limitations.

### Step 0.3 — Determine decision-making format

Ask the user how they want to review and approve the findings:

**Option A — Interactive (recommended for <30 decisions)**
Use the `ask_user_input` tool to present each decision as a choice. Fast, conversational, no file overhead.

**Option B — CSV file (recommended for 30–100 decisions)**
Generate a CSV with columns: `ID, Priority, Domain, Concept, Current_Variants, Occurrences, Recommended, Decision, Override_Value, Notes`. The user opens it in any spreadsheet tool, fills the `Decision` column (accept/reject/override), and provides it back.
```bash
echo "ID,Priority,Domain,Concept,Current_Variants,Occurrences,Recommended,Decision,Override_Value,Notes" > audit_decisions.csv
```

**Option C — Excel file (recommended for 100+ decisions or if user prefers visual review)**
Same structure as CSV but formatted as `.xlsx` with colour-coded priority rows (red=dangerous, yellow=consistency, blue=spelling, grey=style). Use the `xlsx` skill if available, or `openpyxl` directly. Add dropdown validation on `Decision` column (accept/reject/override) and auto-filters on Priority and Domain columns.

**Option D — Markdown checklist (for terminal-only workflows)**
Generate a markdown file with checkboxes grouped by domain with priority icons.

Confirm the user's preference before proceeding. The rest of this skill uses "[DECISION POINT]" markers where user input is collected via the chosen format.

---

## Phase 1: Full Document Scan

### Step 1.1 — Read every file

Read ALL document files. Build a file manifest:

```bash
find [document_root] -name "*.[ext]" -type f | sort
```

For each file, record: filename, line count, word count, sections found.

### Step 1.2 — Run all domain-specific extractions

For each audit domain the user selected, read the corresponding reference file from `references/` and follow its extraction instructions. Each reference file specifies:
- What to look for
- What grep/regex patterns to use
- How to categorise findings
- What constitutes a conflict vs a style choice

**Run all extractions before presenting any findings.** The full picture matters — a formatting issue and a terminology issue on the same line should be flagged together.

### Step 1.3 — Build the raw findings database

Store all findings in a structured format:

```
Finding:
  id: [sequential number]
  domain: [1-9]
  category: [from domain-specific categories]
  severity: [DANGEROUS | CONSISTENCY | SPELLING | STYLE]
  concept: [what concept this relates to]
  variants_found: [{text, file, line, count}]
  recommendation: [suggested standard]
  context_examples: [2-3 representative lines showing the issue]
```

---

## Phase 2: Analysis and Grouping

### Step 2.1 — Group findings into decision clusters

Multiple raw findings may relate to the same decision. Group them:
- All variants of the same term → one terminology decision
- All instances of the same formatting pattern → one formatting decision
- All passive-voice occurrences in a chapter → one tone observation (not one decision per sentence)
- All width specifications for the same figure type → one figure style decision
- All equation environment choices → one math notation decision

### Step 2.2 — Prioritise

| Priority | Label | Criteria | Action mode |
|----------|-------|----------|-------------|
| P1 | 🔴 DANGEROUS | Changes meaning, creates ambiguity, breaks references, redefines a math symbol | Manual review per occurrence |
| P2 | 🟡 CONSISTENCY | Same concept/pattern, different execution across files | Batch with spot-check |
| P3 | 🔵 SPELLING | Language convention violations | Safe batch apply |
| P4 | ⚪ STYLE | Capitalisation, minor formatting, visual polish | Safe batch apply |

### Step 2.3 — Count effort

For each decision cluster, count total replacements needed. Flag any cluster with >50 replacements as "high-effort". For figure style issues (Domain 9), note which figures are regenerable (code-produced) vs fixed (screenshots/external).

---

## Phase 3: Present Findings

### Step 3.1 — Generate the audit report

Structure the report by domain, then by priority within each domain:

```
══════════════════════════════════════════════════════
  DOCUMENT CONSISTENCY AUDIT REPORT
══════════════════════════════════════════════════════

  Document: [name]
  Files scanned: [N]
  Total words: [N]
  Decision clusters found: [N]
    🔴 Dangerous: [N]
    🟡 Consistency: [N]
    🔵 Spelling: [N]
    ⚪ Style: [N]

──────────────────────────────────────────────────────
  DOMAIN 1: TERMINOLOGY
──────────────────────────────────────────────────────
  [findings per references/terminology.md report format]

  ... [repeat for each audited domain 1–9] ...

──────────────────────────────────────────────────────
  CROSS-DOMAIN ISSUES
──────────────────────────────────────────────────────
  [issues that span multiple domains]

══════════════════════════════════════════════════════
  SUMMARY: [N] decisions needed from user
══════════════════════════════════════════════════════
```

### Step 3.2 — [DECISION POINT] Collect user decisions

Using the format chosen in Step 0.3. **HARD STOP: Do NOT proceed until all decisions are confirmed.**

---

## Phase 4: Build Replacement Plan

### Step 4.1 — Generate context-aware replacements

For each confirmed decision, find every occurrence. For EACH:

```
File: [filename]
Line: [number]
Current text: "[exact text with ±20 chars context]"
Replacement: "[corrected text]"
Action: REPLACE | KEEP
Reason: [why this occurrence should/shouldn't change]
```

**Protection rules (always enforced):**
- Never modify `\label{}`, `\ref{}`, `\cite{}`, `[links](url)`, `id=`, or other structural references
- Never modify code blocks, `\texttt{}`, `verbatim`, `lstlisting`, inline code
- Never modify URLs, file paths, or variable names
- Never modify math environments without explicit user approval (all math changes are P1 by default)
- Flag section/chapter headings separately (affect navigation and ToC)
- Flag captions separately (appear in List of Figures/Tables)
- For figure style changes: generate a list of figures to re-export, not sed commands

### Step 4.2 — Generate execution commands

P3+P4 (safe batch): `sed -i` with preview grep.
P2 (consistency): one concept at a time with verification.
P1 (dangerous): grep only, user confirms each line.

### Step 4.3 — Present plan to user for approval

Show total replacement count per priority tier and per file. Ask for go/no-go.

---

## Phase 5: Execute

### Step 5.1 — Apply P3 + P4 (safe)
Apply. Report summary per file.

### Step 5.2 — Apply P2 (consistency)
One concept at a time. Report changes. Pause if >20 replacements for spot-check.

### Step 5.3 — Guide P1 (dangerous)
Show each line. Get explicit confirmation. Apply one at a time.

### Step 5.4 — Verification scan
Re-grep for all old variants. Report any remaining. Confirm completion.

### Step 5.5 — Post-audit checklist
Run the checklist from `references/post-audit-checklist.md`.

---

## Scaling Notes

| Document size | Expected clusters | Recommended decision format | Time estimate |
|--------------|-------------------|---------------------------|---------------|
| <5 files | 10–25 | Interactive | 30 min |
| 5–20 files | 25–80 | CSV or Interactive | 1–2 hours |
| 20–50 files | 80–200 | Excel or CSV | 2–4 hours |
| 50+ files | 200+ | Excel (with filtering) | Half day+ |

If >80 clusters found, ask user to focus on P1+P2 first; P3+P4 in follow-up pass.
