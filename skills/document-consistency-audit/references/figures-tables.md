# Domain 5: Figures & Tables Consistency

## What This Domain Covers

All figures and tables should use the same packages, placement conventions, caption styles, numbering schemes, and cross-referencing patterns. This domain checks for visual and structural consistency in floats.

## Extraction Checklist

### 5.1 Figure Environment Usage

```bash
# Inventory figure environments
for f in [files]; do
    echo "=== $(basename $f) ==="
    grep -c '\\begin{figure}' "$f" && echo " figure"
    grep -c '\\begin{figure\*}' "$f" && echo " figure*"
    grep -c '\\begin{wrapfigure}' "$f" && echo " wrapfigure"
    grep -c '\\subfloat' "$f" && echo " subfloat"
    grep -c '\\subfigure' "$f" && echo " subfigure (deprecated)"
    grep -c '\\begin{subfigure}' "$f" && echo " subfigure env"
    grep -c '\\begin{minipage}' "$f" && echo " minipage"
done
```

**What to flag:**
- `\subfigure` (deprecated) mixed with `\subfloat` or `subcaption`'s `\begin{subfigure}`
- `figure*` (two-column width) used inconsistently
- Some figures in `figure` environment, others inline without any float environment
- `wrapfigure` used in some places but not others for similar content

### 5.2 Table Environment Usage

```bash
# Inventory table environments
for f in [files]; do
    echo "=== $(basename $f) ==="
    grep -c '\\begin{table}' "$f" && echo " table"
    grep -c '\\begin{longtable}' "$f" && echo " longtable"
    grep -c '\\begin{tabular}' "$f" && echo " tabular"
    grep -c '\\begin{booktabs}' "$f" && echo " booktabs"
    grep -c '\\toprule\|\\midrule\|\\bottomrule' "$f" && echo " booktabs rules"
    grep -c '\\hline' "$f" && echo " hline (non-booktabs)"
done
```

**What to flag:**
- `\hline` mixed with `\toprule`/`\midrule`/`\bottomrule` (booktabs). Pick one convention.
- `tabular` without wrapping `table` environment (no float, no caption, no label)
- `longtable` and `table` used for similar-length tables

### 5.3 Placement Specifiers

```bash
# Check float placement specifiers
grep -Pn '\\begin\{figure\}\s*\[.*?\]' [files]
grep -Pn '\\begin\{table\}\s*\[.*?\]' [files]
```

**What to flag:**
- Inconsistent specifiers: some figures `[H]`, others `[htbp]`, others `[!ht]`
- `[H]` (requires `float` package) mixed with standard specifiers
- Missing specifier entirely (LaTeX defaults, but inconsistent with explicit ones)

### 5.4 Caption Style

| Convention | What to check |
|-----------|--------------|
| Position | Caption above table / below figure? Consistent? |
| Content | Full sentence with period? Fragment without period? Mixed? |
| Colon usage | "Figure 1: Description" vs "Figure 1. Description" (handled by caption package, but check manual formatting) |
| Length | One-liners vs multi-sentence captions — is similar content treated similarly? |

```bash
# Extract all captions
grep -n '\\caption{' [files]
```

### 5.5 Cross-Referencing

| Convention | What to check |
|-----------|--------------|
| Reference style | "Figure~\ref{}" vs "Fig.~\ref{}" vs "\autoref{}" vs "\cref{}" |
| Non-breaking space | `~` before `\ref{}`? Consistent? |
| Capitalisation | "Figure 1" vs "figure 1" at start of sentence vs mid-sentence |
| First mention | Is every figure/table referenced in the text BEFORE it appears? |
| Orphan floats | Any figure/table never referenced in text at all? |

```bash
# Find figure/table references
grep -Pn 'Figure~?\\ref|Fig\.~?\\ref|figure~?\\ref|fig\.~?\\ref' [files]
grep -Pn 'Table~?\\ref|table~?\\ref|Tab\.~?\\ref' [files]

# Find labels without references
for label in $(grep -oP '\\label\{fig:[^}]+\}' [files] | sed 's/\\label{//;s/}//'); do
    count=$(grep -rc "\\\\ref{$label}" [files] | awk -F: '{s+=$2}END{print s}')
    if [ "$count" -eq 0 ]; then
        echo "ORPHAN: $label — never referenced"
    fi
done
```

### 5.6 Image File Conventions

| Convention | What to check |
|-----------|--------------|
| Format | All `.png`? All `.pdf`? Mixed? (PDF preferred for vector, PNG for raster) |
| Path style | `figures/` prefix? Subdirectories? Consistent path structure? |
| Width specification | `\includegraphics[width=\textwidth]` vs `[width=0.8\textwidth]` vs `[scale=0.5]` — consistent for similar figure types? |

## Report Format

```
FIGURE & TABLE FINDINGS
========================

🖼️ ENVIRONMENT INCONSISTENCIES:
  [N]. [deprecated/mixed environment] in [file:line]

🖼️ PLACEMENT INCONSISTENCIES:
  [N]. [specifier A] in [file:line], [specifier B] in [file:line]

🖼️ CAPTION STYLE ISSUES:
  [N]. [style A] in [file:line], [style B] in [file:line]

🖼️ CROSS-REFERENCE ISSUES:
  [N]. "[Figure]" vs "[Fig.]" — [count per variant]

🖼️ ORPHAN FLOATS:
  [N]. [label] defined in [file:line] — never referenced in text
```
