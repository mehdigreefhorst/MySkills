# Post-Audit Verification Checklist

Run this checklist after all replacements have been applied. Every item must pass.

## Structural Integrity

- [ ] Document compiles / renders without errors (ask user to verify)
- [ ] No `\label{}` content has been modified
- [ ] No `\ref{}`, `\autoref{}`, or `\cref{}` content has been modified
- [ ] No `\cite{}`, `\citep{}`, `\citet{}` content has been modified
- [ ] No content inside code blocks has been modified (`lstlisting`, `verbatim`, `\texttt{}`, fenced code blocks)
- [ ] No URLs or file paths have been modified
- [ ] No `.bib` keys have been modified
- [ ] No math environments have been modified without explicit user approval
- [ ] All cross-references still resolve (no "??" in compiled output)

## Domain 1: Terminology

- [ ] Every term decision applied in ALL files (re-grep for old variants)
- [ ] No new inconsistencies introduced by replacements
- [ ] Acronyms introduced at first use in every chapter
- [ ] Abstract re-introduces all acronyms
- [ ] Section headings reflect standardised terms
- [ ] Table headers and figure captions reflect standardised terms
- [ ] Spelling convention (British/American) consistent throughout

## Domain 2: Formatting & Styling

- [ ] Emphasis commands consistent (`\emph` vs `\textit` — one convention)
- [ ] Quotation mark style consistent (no straight `"` in LaTeX)
- [ ] Dash usage consistent (no prohibited dash types remaining)
- [ ] Non-breaking spaces `~` present before all `\ref{}` and `\cite{}` commands
- [ ] List punctuation consistent (all semicolons, all periods, or all none)
- [ ] Number formatting consistent (thousands separator, percentage style)
- [ ] Oxford comma usage consistent (all with or all without)

## Domain 3: Tone & Voice

- [ ] Person (I/we/passive) consistent within each chapter
- [ ] Tense consistent within each chapter type
- [ ] No informal language remaining in academic sections (contractions, slang, exclamation marks)
- [ ] No promotional language ("groundbreaking", "revolutionary", etc.)
- [ ] Hedging level consistent for equivalent claims across chapters

## Domain 4: Chapter Structure

- [ ] Every chapter has an opening purpose statement
- [ ] Every chapter has a closing summary or transition
- [ ] No orphan subsections (single child under a parent)
- [ ] Section naming conventions consistent across chapters
- [ ] Section depth consistent across comparable chapters

## Domain 5: Figures & Tables

- [ ] All figures/tables referenced in text before they appear
- [ ] No orphan floats (defined but never referenced)
- [ ] Caption style consistent (full sentence vs fragment, period vs no period)
- [ ] Cross-reference style consistent ("Figure" vs "Fig." — one form only)
- [ ] Placement specifiers consistent (`[H]` vs `[htbp]` — one convention)
- [ ] No deprecated environments (`\subfigure`, `eqnarray`, `$$...$$`)
- [ ] `\hline` and booktabs rules (`\toprule`, `\midrule`, `\bottomrule`) not mixed

## Domain 6: Citations & References

- [ ] Citation command usage consistent (`\cite` vs `\citep` vs `\citet`)
- [ ] Citation placement relative to punctuation consistent
- [ ] No citation-free factual claims in literature review or background
- [ ] Footnote usage consistent (same content type handled the same way)

## Domain 7: Narrative & Story

- [ ] Research question wording identical in Introduction and Conclusion
- [ ] All forward references ("as discussed in Section X") fulfilled
- [ ] All discussion points grounded in specific results
- [ ] Claim strength consistent across chapters (no escalation or deflation)
- [ ] Parallel structures maintained for repeated patterns (MRs, DPs, datasets, experiments)
- [ ] Intro-conclusion mirror: every problem stated in intro is addressed in conclusion

## Domain 8: Mathematical Notation

- [ ] No symbol reuse (same symbol, different meanings in different chapters)
- [ ] Every symbol defined before or at first use
- [ ] Equation environment usage consistent (no deprecated `eqnarray` or `$$...$$`)
- [ ] Equation numbering discipline consistent (numbered only if referenced, or number all)
- [ ] Equation reference style consistent (`Equation~\ref{}` vs `Eq.~\ref{}` vs `\eqref{}`)
- [ ] Standard operators use upright commands (`\log`, `\max`, not italic)
- [ ] Math font conventions consistent (vectors always bold, matrices always bold uppercase, etc.)
- [ ] No orphan numbered equations (numbered but never referenced)

## Domain 9: Figure Size & Visual Style

- [ ] Width specifications consistent for same figure type
- [ ] Sizing method consistent (`width=` vs `scale=` — one convention)
- [ ] `\textwidth` vs `\linewidth` — one convention
- [ ] Subfigure package consistent (`\subfloat` vs `\begin{subfigure}` — one only)
- [ ] Subfigure sizing equal within each figure
- [ ] No hardcoded dimensions where relative widths are appropriate
- [ ] Vector content saved as vector format (PDF), raster content as PNG/JPG
- [ ] Screenshot style consistent (chrome, dark/light mode, annotation style)
- [ ] Diagram style consistent within tool type (shape style, arrow style, colours)
- [ ] No visibly pixelated figures at normal viewing size

## Final Verification Commands

```bash
# Comprehensive remnant check (customise patterns per audit)
echo "=== Remaining old terminology variants ==="
grep -rn "[old_variant_1]\|[old_variant_2]" [files]

echo "=== Broken references (LaTeX log) ==="
grep -i 'undefined\|multiply defined\|Warning.*ref' [log_file]

echo "=== Missing citations (LaTeX log) ==="
grep -i 'undefined citation' [log_file]

echo "=== Remaining straight quotes ==="
grep -Pn '(?<![`\\])"' [files]

echo "=== Remaining informal language ==="
grep -rniP "don't|can't|won't|shouldn't|it's\b" [files]

echo "=== Deprecated math environments ==="
grep -rn '\\begin{eqnarray}\|\$\$' [files]

echo "=== Mixed sizing methods ==="
grep -rn 'scale=' [files]    # check if should all be width=
grep -rn 'width=.*cm\|width=.*in\|width=.*mm' [files]  # hardcoded sizes

echo "=== Orphan equation labels ==="
for label in $(grep -ohP '\\label\{eq:[^}]+\}' [files] | sed 's/\\label{//;s/}//'); do
    refs=$(grep -rc "\\\\ref{$label}\|\\\\eqref{$label}" [files] | awk -F: '{s+=$2}END{print s}')
    [ "$refs" -eq 0 ] && echo "ORPHAN: $label"
done

echo "=== Orphan figure/table labels ==="
for label in $(grep -ohP '\\label\{(fig|tab):[^}]+\}' [files] | sed 's/\\label{//;s/}//'); do
    refs=$(grep -rc "\\\\ref{$label}" [files] | awk -F: '{s+=$2}END{print s}')
    [ "$refs" -eq 0 ] && echo "ORPHAN: $label"
done
```
