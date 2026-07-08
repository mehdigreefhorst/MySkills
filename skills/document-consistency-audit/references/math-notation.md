# Domain 8: Mathematical Notation Consistency

## What This Domain Covers

Every mathematical symbol, equation environment, operator, and notation convention should be used consistently throughout the document. A symbol that means one thing in Chapter 3 must not be silently repurposed in Chapter 5. This domain checks notation discipline, environment usage, font conventions, and equation numbering.

## When to Skip

If the document contains no mathematical notation (pure qualitative thesis, policy report), skip this domain entirely. If the document uses only light notation (a few formulas), run the checks but expect few findings.

## Extraction Checklist

### 8.1 Symbol Inventory

Build a complete symbol table across the entire document.

```bash
# Find all math mode content (LaTeX)
grep -Pn '\$[^$]+\$|\\\([^)]+\\\)|\\\[[^\]]+\\\]' [files]

# Find all equation environments
grep -n '\\begin{equation\|\\begin{align\|\\begin{gather\|\\begin{multline\|\\begin{eqnarray' [files]
```

For each symbol found, record:

| Field | Description |
|-------|-------------|
| Symbol | The LaTeX code (e.g., `\alpha`, `n`, `\mathcal{D}`) |
| Meaning | What it represents in context |
| File | Where it appears |
| First introduced | File and line of first occurrence |
| Formally defined | Is there an explicit "let X denote Y" statement? |

**What to flag:**

| Issue | Example | Severity |
|-------|---------|----------|
| ⚠️ Symbol reuse | `$n$` means "number of documents" in Ch5 but "number of debate rounds" in Ch6 | DANGEROUS |
| ⚠️ Symbol redefinition | `$\alpha$` defined as learning rate in one section, significance level in another | DANGEROUS |
| Undefined symbol | Symbol used in equation but never defined in surrounding text | CONSISTENCY |
| Late definition | Symbol used on page 30, defined on page 45 | CONSISTENCY |

### 8.2 Equation Environment Consistency

Different environments serve different purposes. They must not be mixed randomly.

| Environment | Purpose | Numbering |
|------------|---------|-----------|
| `equation` | Single numbered equation | Yes |
| `equation*` | Single unnumbered equation | No |
| `align` | Multi-line aligned equations | Yes (each line) |
| `align*` | Multi-line aligned, unnumbered | No |
| `gather` | Multi-line centred, no alignment | Yes |
| `multline` | Long equation, split across lines | Yes |
| `eqnarray` | DEPRECATED — should not be used | Inconsistent spacing |
| `$...$` / `\(...\)` | Inline math | N/A |
| `$$...$$` | DEPRECATED display math in LaTeX | N/A |
| `\[...\]` | Display math (unnumbered) | No |

```bash
# Count environment usage
for env in equation equation* align align* gather multline eqnarray; do
    count=$(grep -rc "\\\\begin{$env}" [files] | awk -F: '{s+=$2}END{print s}')
    echo "$env: $count"
done

# Check for deprecated $$...$$ usage
grep -Pn '\$\$' [files]

# Check for deprecated eqnarray
grep -n '\\begin{eqnarray}' [files]
```

**What to flag:**
- `eqnarray` used anywhere (should be `align`)
- `$$...$$` used (should be `\[...\]` or `equation*`)
- Equivalent equations using different environments across chapters (e.g., single equation in `equation` in Ch5 but `align` with one line in Ch8)
- Numbered equations that are never referenced (waste of a number)
- Unnumbered equations that ARE referenced (impossible to reference)

### 8.3 Numbering Discipline

| Check | What to verify |
|-------|---------------|
| Numbered vs unnumbered | Consistent policy: number all, number only referenced, or number none? |
| Referencing style | `Equation~\ref{eq:X}` vs `Eq.~\ref{eq:X}` vs `(\ref{eq:X})` vs `\eqref{eq:X}` |
| Label naming | `eq:consensus-threshold` vs `eq:1` vs `equation:consensus` — consistent scheme? |
| Orphan numbers | Numbered equations never referenced anywhere |

```bash
# Find equation labels
grep -oP '\\label\{eq:[^}]+\}' [files] | sort

# Find equation references
grep -oP '\\ref\{eq:[^}]+\}|\\eqref\{eq:[^}]+\}' [files] | sort

# Cross-check: labels without references
for label in $(grep -ohP '\\label\{eq:[^}]+\}' [files] | sed 's/\\label{//;s/}//'); do
    refs=$(grep -rc "\\\\ref{$label}\|\\\\eqref{$label}" [files] | awk -F: '{s+=$2}END{print s}')
    [ "$refs" -eq 0 ] && echo "ORPHAN: $label (numbered but never referenced)"
done
```

### 8.4 Operator and Function Formatting

Standard mathematical functions should use upright (roman) font, not italic. LaTeX provides commands for these.

| Correct | Incorrect | Why |
|---------|-----------|-----|
| `\log` | `log` (italic) | Standard function |
| `\max`, `\min` | `max`, `min` | Standard function |
| `\arg\max` | `argmax` or `\text{argmax}` | Operator |
| `\cos`, `\sin` | `cos`, `sin` | Standard function |
| `\Pr` | `Pr` (italic) | Probability |
| `\operatorname{softmax}` | `softmax` (italic) | Custom operator |
| `\mathrm{d}x` | `dx` (italic d) | Differential (convention-dependent) |
| `\mathbb{R}` | `R` (italic) | Number set |

```bash
# Find potentially mis-formatted operators (italic where should be upright)
grep -Pn '\$[^$]*(log|max|min|arg|cos|sin|exp|det|dim|inf|sup|lim|Pr)\b[^$]*\$' [files] | grep -v '\\log\|\\max\|\\min\|\\cos\|\\sin\|\\exp\|\\det\|\\dim\|\\inf\|\\sup\|\\lim\|\\Pr\|\\arg\|\\operatorname'
```

### 8.5 Font Consistency in Math Mode

| Convention | LaTeX | Usage |
|-----------|-------|-------|
| Default italic | `$x$` | Variables |
| Bold italic | `$\boldsymbol{x}$` or `$\bm{x}$` | Vectors |
| Bold upright | `$\mathbf{X}$` | Matrices |
| Calligraphic | `$\mathcal{L}$` | Loss functions, special sets |
| Blackboard bold | `$\mathbb{R}$` | Number sets |
| Sans-serif | `$\mathsf{T}$` | Transpose (convention-dependent) |
| Roman/upright | `$\mathrm{text}$` | Units, abbreviations in math |
| Text in math | `$\text{some text}$` | Words inside equations |

**What to flag:**
- Vectors sometimes bold, sometimes not
- Matrices sometimes uppercase bold, sometimes plain uppercase
- Sets sometimes calligraphic, sometimes not
- `\text{}` and `\mathrm{}` used interchangeably (different: `\text{}` inherits surrounding font, `\mathrm{}` is always roman)

### 8.6 Inline vs Display Math Threshold

Is there a consistent policy for when math goes inline vs displayed? Common rule: equations with more than 2–3 terms or with fractions/summations should be displayed. Check for:

- Long inline equations that overflow the text margin
- Very short display equations that could be inline
- Inconsistency: equivalent-complexity expressions inline in one place but displayed in another

### 8.7 Notation Glossary

Does the document have a notation table or glossary? If yes, does every symbol in the glossary actually appear in the document, and does every symbol in the document appear in the glossary?

## Report Format

```
MATHEMATICAL NOTATION FINDINGS
===============================

⚠️ SYMBOL CONFLICTS:
  [N]. Symbol [X] means "[A]" in [file:line] but "[B]" in [file:line]

📐 ENVIRONMENT INCONSISTENCIES:
  [N]. [deprecated/mixed environment] in [file:line]
    Recommendation: use [correct environment]

📐 NUMBERING ISSUES:
  [N]. [orphan numbered eq / unnumbered referenced eq] in [file:line]

📐 OPERATOR FORMATTING:
  [N]. [operator] in italic in [file:line] — should use [correct command]

📐 FONT INCONSISTENCIES:
  [N]. [symbol type] formatted as [X] in [file] but [Y] in [file]

📐 REFERENCE STYLE:
  [N]. "Equation~\ref{}" vs "Eq.~\ref{}" — [count per variant]
```
