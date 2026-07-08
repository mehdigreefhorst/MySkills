# Domain 6: Citations & References Consistency

## What This Domain Covers

All citations and references should use the same commands, the same style, and follow the same conventions for when to cite, how to cite, and how to handle multiple references.

## Extraction Checklist

### 6.1 Citation Command Usage

Different citation commands serve different purposes. They must not be mixed randomly.

| Command | Purpose | Renders as (natbib/apacite) |
|---------|---------|---------------------------|
| `\cite{}` | Generic / textual | "Author (Year)" |
| `\citep{}` | Parenthetical | "(Author, Year)" |
| `\citet{}` | Textual (explicit) | "Author (Year)" |
| `\citeauthor{}` | Author name only | "Author" |
| `\citeyear{}` | Year only | "Year" |
| `\citealp{}` | Parenthetical without brackets | "Author, Year" |

```bash
# Count citation command types per file
for f in [files]; do
    echo "=== $(basename $f) ==="
    echo "  \\cite: $(grep -oP '\\\\cite\{' "$f" | wc -l)"
    echo "  \\citep: $(grep -oP '\\\\citep\{' "$f" | wc -l)"
    echo "  \\citet: $(grep -oP '\\\\citet\{' "$f" | wc -l)"
    echo "  \\citeauthor: $(grep -oP '\\\\citeauthor\{' "$f" | wc -l)"
done
```

**What to flag:**
- `\cite{}` and `\citep{}` used interchangeably for the same context (parenthetical)
- Some chapters use `\citep{}` exclusively, others use `\cite{}` for the same purpose
- `\citet{}` never used when it should be (textual citations in prose)
- `\cite{}` used where `\citep{}` is needed (e.g., end-of-sentence parenthetical)

**Ask the user:** Which citation style is intended? Common patterns:
- **Pattern A:** `\citep{}` for all parenthetical, `\citet{}` for textual → most explicit
- **Pattern B:** `\cite{}` for everything (if the package auto-detects) → simpler but less control
- **Pattern C:** Mixed based on natbib/apacite conventions → check package documentation

### 6.2 Citation Placement

| Convention | What to check |
|-----------|--------------|
| Before or after period | "...is well established \citep{X}." vs "...is well established. \citep{X}" |
| Before or after comma | Consistent placement relative to punctuation |
| Space before | Non-breaking space `~\citep{}` vs regular space |
| Multiple citations | `\citep{A, B, C}` vs `\citep{A}\citep{B}\citep{C}` vs `\citep{A}; \citep{B}` |

```bash
# Citations before/after period
grep -Pn '\\cite[pt]?\{[^}]+\}\.' [files] | head -10   # cite then period
grep -Pn '\.\s*\\cite[pt]?\{' [files] | head -10        # period then cite
```

### 6.3 Citation Density and Distribution

| Check | What to look for |
|-------|-----------------|
| Uncited claims | Factual statements without any citation — especially in literature review and background |
| Over-citation | Same claim supported by 5+ references where 2–3 would suffice |
| Self-citation | Frequency and appropriateness |
| Stale citations | Very old references when newer ones exist |
| Citation-free sections | Entire sections (especially in lit review) with no citations — likely an oversight |

```bash
# Find paragraphs without any citation (rough heuristic: long lines without \cite)
awk '/^[A-Z]/ && length > 200 && !/\\cite/' [files]
```

### 6.4 Footnote Usage

| Convention | What to check |
|-----------|--------------|
| Purpose | Are footnotes used for tangential information, for citations, or for both? |
| Consistency | Same type of content in footnotes in one chapter but in main text in another? |
| Frequency | Excessive footnotes (>3 per page) suggest content should be in main text or appendix |
| Prohibition | Some academic styles discourage or ban footnotes. Ask the user. |

```bash
grep -c '\\footnote{' [files]
```

### 6.5 Bibliography Key Consistency

| Check | What to look for |
|-------|-----------------|
| Key format | Are bib keys consistent? (e.g., `author2024`, `AuthorYear`, `author2024topic`) |
| Missing entries | Any `\cite{X}` where X is not in the `.bib` file? (LaTeX will warn, but check) |
| Duplicate entries | Same work cited under different keys? |
| Unused entries | Bib entries never cited? (Not necessarily wrong, but worth noting) |

## Report Format

```
CITATION FINDINGS
=================

📚 COMMAND INCONSISTENCIES:
  [N]. \\cite used parenthetically in [file:line] — should be \\citep
  [N]. \\cite and \\citep mixed for same context across chapters

📚 PLACEMENT ISSUES:
  [N]. Citation [before/after] period: [count per pattern]

📚 DENSITY ISSUES:
  [N]. [section] has [N] paragraphs without citations

📚 FOOTNOTE ISSUES:
  [N]. [description]
```
