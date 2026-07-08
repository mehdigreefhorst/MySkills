# Domain 2: Formatting & Styling Consistency

## What This Domain Covers

Every formatting convention (emphasis, quotation marks, dashes, code formatting, delimiters, whitespace) should be applied uniformly across the entire document. This domain finds cases where the same type of content is formatted differently in different places.

## Extraction Checklist

### 2.1 Emphasis Commands

Check that the same type of content always receives the same emphasis treatment.

**What to scan for:**

| Convention | LaTeX | Markdown | What to check |
|-----------|-------|----------|--------------|
| Bold | `\textbf{}` | `**text**` | Is bold used for the same purpose everywhere? (e.g., always for defined terms, or always for UI elements) |
| Italic | `\textit{}`, `\emph{}` | `*text*`, `_text_` | Is italic used consistently? (e.g., always for foreign words, always for first introduction of a term) |
| Monospace/code | `\texttt{}` | `` `code` `` | Is code formatting applied to all technical names, or only some? |
| Small caps | `\textsc{}` | N/A | Consistent usage? |
| Underline | `\underline{}` | N/A | Used at all? Usually discouraged in academic writing. |

```bash
# LaTeX: count emphasis usage
echo "=== Emphasis usage ==="
grep -rc '\\textbf{' [files] | grep -v ':0$'
grep -rc '\\textit{' [files] | grep -v ':0$'
grep -rc '\\emph{' [files] | grep -v ':0$'
grep -rc '\\texttt{' [files] | grep -v ':0$'
grep -rc '\\textsc{' [files] | grep -v ':0$'
grep -rc '\\underline{' [files] | grep -v ':0$'
```

**Conflict patterns to check:**
- `\textit{}` and `\emph{}` used interchangeably (they render the same but have different semantic meaning — `\emph{}` is semantic, `\textit{}` is visual)
- `\textbf{}` used for term definitions in one chapter but not another
- `\texttt{}` used for some technical names but not others of the same type
- Framework/tool name sometimes in `\texttt{}`, sometimes plain, sometimes bold

### 2.2 Quotation Marks

Different quotation conventions must not be mixed within a document.

**What to scan for:**

| Style | Characters | Usage |
|-------|-----------|-------|
| LaTeX double quotes | `` `` ... '' `` | Standard LaTeX |
| LaTeX single quotes | `` ` ... ' `` | Standard LaTeX |
| Straight double quotes | `"..."` | WRONG in LaTeX — renders as closing-closing |
| Unicode curly quotes | `"..."` / `'...'` | May cause encoding issues |
| French quotes | `«...»` | Some European conventions |

```bash
# LaTeX: find quotation mark styles
grep -Pn '(?<![`\\])"' [files]          # straight double quotes (likely wrong)
grep -Pn "``" [files]                    # LaTeX opening double quotes
grep -Pn "''" [files]                    # LaTeX closing double quotes
grep -Pn '(?<![`])`(?!`)' [files]       # LaTeX single open quotes
```

**Key rule:** Within one document, only one quotation convention should appear. If LaTeX, always use ``` `` ... '' ```. If a user types `"..."`, flag it.

Also check: Are quotation marks used for the same purpose everywhere? (e.g., always for direct quotes, or always for scare quotes / term introduction, but not mixed)

### 2.3 Dashes

Three types of dashes exist. They must be used consistently for their intended purpose.

| Dash | LaTeX | Markdown | Correct usage |
|------|-------|----------|--------------|
| Hyphen | `-` | `-` | Compound words: "well-known", "multi-agent" |
| En-dash | `--` | `–` | Ranges: "pages 1--10", "2020--2025" |
| Em-dash | `---` | `—` | Parenthetical: "the tool---which was built---performed well" |

```bash
# Find dash usage
grep -Pn '---' [files]    # em-dashes
grep -Pn '(?<!-)--(?!-)' [files]  # en-dashes (not part of em-dash)
```

**Common issues:**
- Em-dashes prohibited by style guide but still present
- En-dashes used where hyphens are correct (or vice versa)
- Spaces around em-dashes inconsistent (some with spaces, some without)
- Double-hyphen `--` in prose when an en-dash or em-dash was intended

**Ask the user:** Does the style guide prohibit em-dashes? Some academic guides (and some supervisors) explicitly ban them. If so, every `---` must be replaced with commas, semicolons, parentheses, or sentence restructuring.

### 2.4 Delimiter Conventions (Semicolons, Colons, Commas)

Check that list delimiters and clause connectors are used consistently:

- **Semicolons in lists:** If one enumerated list uses semicolons between items, all should
- **Colons before lists:** Consistent introduction style ("the following:" vs "as follows:" vs no colon)
- **Oxford comma:** Consistent use or non-use of the serial comma ("A, B, and C" vs "A, B and C")
- **Semicolons in compound sentences:** Used correctly (between independent clauses) or overused

```bash
# Find semicolons in running text
grep -n ';' [files] | head -30
# Find colon usage before lists
grep -n ':\\s*$\|: \\begin{' [files]
```

### 2.5 Whitespace and Line Conventions

| Convention | What to check |
|-----------|--------------|
| Paragraph separation | Consistent method: blank line, `\par`, `\\`, `\bigskip`? |
| Sentence spacing | Single space after period or double space? |
| Line breaks within paragraphs | Present or absent? (Some styles require one-line-per-paragraph in source) |
| Indentation | First line of paragraph indented or not? Consistent? |
| Non-breaking spaces | Used before `\ref{}`, `\cite{}`? (e.g., `Section~\ref{...}`) |
| Tilde usage | `~` used consistently for non-breaking spaces? |

```bash
# Check for non-breaking space before references
grep -Pn '(?<!~)\\ref\{' [files]         # \ref without preceding ~
grep -Pn '(?<!~)\\cite[pt]?\{' [files]   # \cite without preceding ~
```

### 2.6 Number and Unit Formatting

| Convention | What to check |
|-----------|--------------|
| Number spelling | "three" vs "3" — is there a consistent threshold? (common: spell out below 10) |
| Thousands separator | "10,000" vs "10000" vs "10.000" |
| Decimal separator | "0.5" vs "0,5" |
| Percentage | "50%" vs "50 %" vs "50 per cent" vs "50 percent" |
| Units | Space between number and unit? "5GB" vs "5 GB" vs "5~GB" |

### 2.7 Horizontal Rules, Section Breaks, Spacing Commands

Check for consistency in how visual separation is created:
- `\vspace{}`, `\bigskip`, `\medskip`, `\smallskip` — used consistently?
- `\noindent` — used sparingly and for the same purpose?
- `\newpage`, `\clearpage` — used consistently at chapter boundaries?

## Report Format

```
FORMATTING FINDINGS
===================

📝 EMPHASIS INCONSISTENCIES:
  [N]. [content type] formatted as [X] in [file] but [Y] in [file]
    Occurrences: [count per variant]
    Recommendation: [standard]

📝 QUOTATION MARK ISSUES:
  [N]. [style A] in [file:line], [style B] in [file:line]
    Recommendation: [standard]

📝 DASH ISSUES:
  [N]. [type] used in [file:line] — should be [correct type]

📝 DELIMITER INCONSISTENCIES:
  [N]. [description]

📝 WHITESPACE ISSUES:
  [N]. [description] — [file:line]
```
