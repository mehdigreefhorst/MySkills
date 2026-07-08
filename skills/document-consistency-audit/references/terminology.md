# Domain 1: Terminology Consistency

## What This Domain Covers

Every concept in the document should be referred to by the same term throughout. This domain finds cases where the same concept has multiple names, flags dangerous semantic conflicts, and verifies acronym discipline.

## Extraction Checklist

### 1.1 Term Categories

Extract all domain-specific terms into these categories:

| Category | Description | Examples |
|----------|-------------|---------|
| A — Project-specific | Terms the document introduces | Framework names, method names, stage names, data structure names |
| B — Technical domain | Established terms from the field | Algorithm names, metric names, methodology terms |
| C — Application domain | Terms from the subject area | Industry terms, community names, dataset names |
| D — Evaluation | Terms for how the work was assessed | Study type names, instrument names, construct names |

### 1.2 Variation Types to Check

For every concept, systematically check for:

| Variation type | Example |
|---------------|---------|
| Capitalisation | "multi-agent debate" vs "Multi-Agent Debate" |
| Hyphenation | "multi-agent" vs "multi agent" vs "multiagent" |
| Abbreviation | "DHH" vs "deaf and hard of hearing" |
| Synonym | "tool" vs "framework" vs "artifact" vs "system" |
| Compound forms | "ground truth" vs "ground-truth" vs "GT" |
| Singular/plural in equivalent contexts | "design principle" vs "design principles" |
| Definite article | "the framework" vs "[Name]" vs "our framework" |
| Spelling variant | "modelling" vs "modeling" |
| Word order | "topic model" vs "model of topics" |

### 1.3 Dangerous Conflict Detection

A dangerous conflict is when the same word is used for two different concepts, or when a characterisation term is inaccurate. These change meaning, not just style.

**Detection method:**
1. List every term that appears in more than one conceptual context
2. For each, check whether both usages mean the same thing
3. If not, flag as ⚠️ DANGEROUS

**Common dangerous patterns:**
- A general word (e.g., "labels", "features", "model") used for two different technical concepts
- A characterisation (e.g., "quality-improving") that contradicts the actual finding
- A methodological term (e.g., "semi-supervised") used loosely outside its precise meaning

### 1.4 Spelling Convention Check

Determine the declared language convention, then scan for violations.

```bash
# Detect convention (LaTeX)
grep -r "babel" *.tex *.sty | grep -oE "(british|american|english)"

# Common British vs American pairs to scan
grep -rn "modeling\|labeling\|behavior\|generalization\|optimization\|analyze\b\|color\b\|organization\|recognized\|summarize\|defense\b\|catalog\b\|center\b" [files]
```

**Full British/American pair list:**

| British | American |
|---------|----------|
| modelling | modeling |
| labelling | labeling |
| behaviour | behavior |
| generalisation | generalization |
| optimisation | optimization |
| analyse | analyze |
| colour | color |
| organisation | organization |
| recognised | recognized |
| summarise | summarize |
| defence | defense |
| licence (noun) | license |
| catalogue | catalog |
| centre | center |
| programme | program (except computing) |
| judgement | judgment |
| fulfil | fulfill |
| enrol | enroll |
| travelled | traveled |
| cancelled | canceled |
| focussed / focused | focused (both accept "focused") |
| grey | gray |
| manoeuvre | maneuver |
| specialise | specialize |
| artefact | artifact |

### 1.5 Acronym Discipline

```bash
# Find all acronyms (2+ consecutive uppercase letters)
grep -oE '\b[A-Z]{2,}\b' [files] | sort | uniq -c | sort -rn
```

For each acronym verify:
1. **Introduced at first use** with full form: "Design Science Research (DSR)"
2. **Re-introduced per chapter** if chapters may be read independently
3. **Re-introduced in abstract** (abstracts are standalone)
4. **Used consistently** after introduction (no random switches to full form)
5. **Not used before introduction** (no forward references to undefined acronyms)

## Report Format

```
TERMINOLOGY FINDINGS
====================

⚠️ DANGEROUS CONFLICTS:
  [N]. [concept] — "[term A]" means [X], but same word means [Y] in [file:line]

📌 VARIANT CLUSTERS:
  [N]. [concept]
    a) "[variant]" — [count] occ. — [files]
    b) "[variant]" — [count] occ. — [files]
    Dominant: [most frequent]
    Recommendation: [suggested form]

🔤 SPELLING VIOLATIONS:
  [word] → [correct form] — [file:line] — [count] occ.

🔠 ACRONYM ISSUES:
  [acronym] — [issue] — [file:line]
```
