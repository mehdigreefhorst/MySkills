# Domain 3: Tone & Voice Consistency

## What This Domain Covers

The document's voice (active/passive, person, tense) and tone (academic/informal, confident/hedged, instructional/descriptive) should be consistent within chapters and appropriate per chapter type. This domain identifies shifts that break the reading experience.

## Key Principle

Not every chapter needs the same tone. A methodology chapter is naturally more instructional than a results chapter. The goal is **consistency within chapter types** and **appropriate register per chapter type**, not a single tone everywhere.

## Extraction Checklist

### 3.1 Person and Voice

| Convention | Acceptable contexts | Flag if found in |
|-----------|-------------------|-----------------|
| First person singular ("I") | Preface, acknowledgements, personal reflection | Methodology, results, literature review |
| First person plural ("we") | DSR theses, multi-author work, editorial "we" | Inconsistent with "I" in same document |
| Third person ("the author", "this study") | Formal academic writing | Mixed with "we" in same chapter |
| Passive voice ("was performed", "is shown") | Results reporting, methodology | Overuse (>60% of sentences in a section) |
| Active voice ("we performed", "the framework processes") | Implementation, framework description | N/A (generally preferred) |
| Imperative ("consider", "note that") | Instructional sections, reader guidance | Results, literature review |

```bash
# Detect person usage per file
for f in [files]; do
    echo "=== $(basename $f) ==="
    echo "  I/my/me (1st sing): $(grep -oiP '\b(I|my|me)\b' "$f" | wc -l)"
    echo "  we/our/us (1st plur): $(grep -oiP '\b(we|our|us)\b' "$f" | wc -l)"
    echo "  passive markers: $(grep -oiP '\b(was|were|been|being|is|are)\s+(performed|conducted|shown|found|observed|noted|used|applied|obtained|achieved|evaluated|validated|implemented|developed|designed|presented)' "$f" | wc -l)"
done
```

**What to flag:**
- "I" and "we" mixed in the same chapter
- "we" in some chapters but "this study" in others (pick one convention)
- Passive voice used in implementation/framework chapters where active would be clearer
- Active voice used in results where passive is more appropriate for objectivity

### 3.2 Tense Consistency

| Tense | Appropriate for | Flag if |
|-------|----------------|---------|
| Present ("the framework processes...") | Implementation description, general truths, current-state descriptions | Mixed with past tense for the same system |
| Past ("the framework processed...") | Reporting completed experiments, describing what was done | Mixed with present for the same experiment |
| Present perfect ("has been shown") | Connecting past work to current relevance | Overuse |
| Future ("will be discussed") | Previewing upcoming sections | Used for work already completed |

**Key rules:**
- Implementation chapters: present tense for active system, past tense for superseded designs
- Results chapters: past tense for what was measured/observed
- Literature review: present tense for established facts, past tense for specific study actions
- Discussion: present tense for interpretations, past tense for what was found

```bash
# Sample tense patterns per file
for f in [files]; do
    echo "=== $(basename $f) ==="
    echo "  present tense signals: $(grep -oiP '\b(processes|implements|generates|provides|enables|produces|computes|extracts|performs)\b' "$f" | wc -l)"
    echo "  past tense signals: $(grep -oiP '\b(processed|implemented|generated|provided|enabled|produced|computed|extracted|performed)\b' "$f" | wc -l)"
done
```

### 3.3 Register and Formality

| Register | Markers | Appropriate for |
|----------|---------|----------------|
| **Academic formal** | "Furthermore", "consequently", "it should be noted", impersonal constructions | Literature review, methodology, discussion |
| **Academic neutral** | Clear, direct prose without hedging or informality | Implementation, results |
| **Informal** | Contractions ("don't", "can't"), colloquialisms, slang, exclamation marks | NEVER in academic writing (flag all) |
| **Instructional** | Imperative ("note that", "consider"), second person ("you") | Rare in theses; may appear in tool documentation |
| **Promotional** | Superlatives ("groundbreaking", "revolutionary"), marketing language | NEVER in academic writing (flag all) |

```bash
# Detect informality
grep -rniP "don't|can't|won't|shouldn't|couldn't|wouldn't|isn't|aren't|it's\b" [files]
# Detect promotional language
grep -rniP "groundbreaking|revolutionary|game-changing|cutting-edge|state-of-the-art|novel approach|unique\b|first-ever|unprecedented" [files]
# Detect exclamation marks in body text
grep -n '!' [files]
```

### 3.4 Hedging Consistency

Hedging (cautious language) should be consistent. A thesis that says "this conclusively proves" in one section and "this may suggest" in another for equivalent findings has a hedging inconsistency.

| Hedging level | Markers |
|--------------|---------|
| **Strong claim** | "demonstrates", "proves", "establishes", "confirms", "shows" |
| **Moderate claim** | "indicates", "suggests", "supports", "provides evidence" |
| **Weak claim** | "may suggest", "could indicate", "appears to", "seems to" |
| **No claim** | "is observed", "is noted" (purely descriptive) |

**What to flag:**
- Same finding described with strong language in one chapter but weak language in another
- Results section making strong claims that the discussion then hedges (or vice versa)
- Conclusion making stronger claims than the evidence supports

### 3.5 Sentence Patterns

| Pattern | Issue |
|---------|-------|
| Sentence length variation | Are all sentences the same length? (Monotonous) Or is there healthy variation? |
| Paragraph length | Are paragraphs consistently 3–8 sentences? Any single-sentence paragraphs? Any page-long paragraphs? |
| Topic sentences | Do paragraphs start with a clear topic sentence? Consistently? |
| Transition words | Are they used? Overused? ("However", "Furthermore", "Moreover" every paragraph) |

```bash
# Find very short paragraphs (potential orphans) in LaTeX
grep -Pn '^\s*\S.{0,40}$' [files] | grep -v '\\\\section\|\\\\subsection\|\\\\label\|\\\\begin\|\\\\end\|%'
```

## Report Format

```
TONE & VOICE FINDINGS
=====================

🗣️ PERSON/VOICE INCONSISTENCIES:
  [N]. Chapter [X] uses "[we]" ([count] times) but Chapter [Y] uses "[I]" ([count] times)
    Recommendation: [standardise to X]

🗣️ TENSE INCONSISTENCIES:
  [N]. [file] section [X] uses present tense for [topic] but section [Y] uses past tense for same
    Recommendation: [which tense]

🗣️ REGISTER VIOLATIONS:
  [N]. [informal/promotional marker] found in [file:line]
    Context: "[surrounding text]"
    Recommendation: [formal alternative]

🗣️ HEDGING INCONSISTENCIES:
  [N]. [finding X] described as "[strong claim]" in [file:line] but "[weak claim]" in [file:line]
    Recommendation: [appropriate hedging level]
```
