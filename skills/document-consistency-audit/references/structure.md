# Domain 4: Chapter Structure Consistency

## What This Domain Covers

Every chapter should follow a consistent internal pattern: how it opens, how sections are structured, how it closes, and how deeply it nests subsections. This domain checks that structural conventions are applied uniformly.

## Extraction Checklist

### 4.1 Chapter Opening Pattern

Check whether every chapter opens the same way:

| Pattern element | Check |
|----------------|-------|
| Purpose statement | Does the first paragraph explain what this chapter covers? |
| Structure preview | Does it list the sections? ("Section X.1 covers..., Section X.2 presents...") |
| Context bridge | Does it connect to the previous chapter? |
| Scope statement | Does it define what is in-scope and out-of-scope? |

```bash
# Extract first 10 lines of each chapter
for f in [files]; do
    echo "=== $(basename $f) ==="
    sed -n '/\\chapter{/,+10p' "$f"
    echo ""
done
```

**What to flag:**
- Some chapters have structure previews but others don't
- Some chapters bridge from the previous chapter but others start cold
- Opening paragraph style varies wildly between chapters

### 4.2 Chapter Closing Pattern

Check whether every chapter closes the same way:

| Pattern element | Check |
|----------------|-------|
| Summary paragraph | Does the last paragraph summarise the chapter? |
| Transition sentence | Does it preview the next chapter? |
| `\section{Summary}` | Is there a formal summary section? In all chapters or just some? |

```bash
# Extract last 10 lines before next \chapter or end
for f in [files]; do
    echo "=== $(basename $f) ==="
    tail -15 "$f"
    echo ""
done
```

### 4.3 Section Depth Consistency

Check that nesting depth is consistent across chapters.

```bash
# Count section depth per file
for f in [files]; do
    echo "=== $(basename $f) ==="
    echo "  \\chapter: $(grep -c '\\chapter{' "$f")"
    echo "  \\section: $(grep -c '\\section{' "$f")"
    echo "  \\subsection: $(grep -c '\\subsection{' "$f")"
    echo "  \\subsubsection: $(grep -c '\\subsubsection{' "$f")"
    echo "  \\paragraph: $(grep -c '\\paragraph{' "$f")"
done
```

**What to flag:**
- One chapter uses `\paragraph{}` extensively while others never do
- Orphan subsections: `\subsection{X}` without a sibling `\subsection{Y}` (you should never have just one subsection)
- Inconsistent depth: one chapter goes to `\subsubsection` while similar chapters only go to `\subsection`
- `\paragraph{}` used where `\subsubsection{}` would be more appropriate (or vice versa)

### 4.4 Section Naming Conventions

Check that equivalent sections across chapters are named consistently:

| Section type | Variants to check |
|-------------|------------------|
| Summary sections | "Summary" vs "Chapter Summary" vs "Conclusion" vs none |
| Overview sections | "Overview" vs "Introduction" vs "[Topic] Overview" |
| Limitations sections | "Limitations" vs "Limitations and Future Work" vs "Threats to Validity" |
| Design rationale | "Design Rationale" vs "Design Decisions" vs "Design Choices" |

### 4.5 Self-Containment Check

Some chapters (typically Introduction and Conclusion) should be self-contained: readable without the rest of the document. Check:

- Does the introduction explain the thesis without requiring the reader to have read the literature review?
- Does the conclusion summarise findings without requiring the reader to have read the results?
- Do self-contained chapters re-introduce key concepts or only use `\ref{}` to other chapters?

### 4.6 Bullet Points and Lists

| Convention | Check |
|-----------|-------|
| List style | `itemize` vs `enumerate` vs inline lists ("first, ...; second, ...; third, ...") |
| Consistency | Same type of content always listed the same way? |
| Prohibition | Some styles prohibit bullet points in body prose (only in appendices). Ask the user. |
| Punctuation | List items ending with periods vs semicolons vs nothing. Consistent? |

```bash
# Count list environments per file
for f in [files]; do
    echo "=== $(basename $f) ==="
    echo "  itemize: $(grep -c '\\begin{itemize}' "$f")"
    echo "  enumerate: $(grep -c '\\begin{enumerate}' "$f")"
done
```

## Report Format

```
STRUCTURE FINDINGS
==================

🏗️ CHAPTER OPENING INCONSISTENCIES:
  [N]. Chapter [X] has [pattern A], Chapter [Y] has [pattern B]
    Recommendation: [standard pattern]

🏗️ CHAPTER CLOSING INCONSISTENCIES:
  [N]. Chapter [X] has [summary/transition/nothing], Chapter [Y] has [different]
    Recommendation: [standard pattern]

🏗️ SECTION DEPTH ISSUES:
  [N]. [file] has orphan subsection / inconsistent depth

🏗️ NAMING INCONSISTENCIES:
  [N]. Equivalent sections named differently: "[A]" vs "[B]"

🏗️ SELF-CONTAINMENT ISSUES:
  [N]. [chapter] references [concept] without re-introduction
```
