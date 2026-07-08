# Domain 7: Narrative & Story Consistency

## What This Domain Covers

The document should tell a coherent story from beginning to end. Claims made in early chapters should be supported in later chapters. Conclusions should not introduce new concepts. The "red thread" (central argument) should be traceable through every chapter. This domain checks for narrative coherence, parallel structures, and claim consistency.

## Key Principle

This is the hardest domain to audit mechanically. It requires reading the document for meaning, not just pattern-matching. Use grep for verification, but the primary analysis is semantic.

## Extraction Checklist

### 7.1 Red Thread Traceability

The document should have a central argument or research question that is visible in every chapter. Check:

| Chapter type | How the red thread should appear |
|-------------|--------------------------------|
| Introduction | States the problem, question, and approach |
| Literature review | Shows the gap that motivates the question |
| Methodology | Explains how the question will be answered |
| Implementation/Framework | Describes what was built to answer the question |
| Results | Presents evidence that answers the question |
| Discussion | Interprets the evidence in light of the question |
| Conclusion | Explicitly answers the question |

**What to flag:**
- A chapter that never references the research question or the central problem
- A chapter that introduces a major topic not foreshadowed in the introduction
- The conclusion answering a slightly different question than the one stated in the introduction

### 7.2 Claim Consistency

The same finding or claim should be described with the same strength and the same characterisation everywhere it appears.

**Method:**
1. Extract all claims from the Results chapter
2. Find where each claim is re-stated (Discussion, Conclusion, Abstract)
3. Compare the wording, strength, and characterisation

| What to check | Example of inconsistency |
|--------------|------------------------|
| Strength escalation | Results: "may suggest" → Conclusion: "demonstrates" |
| Strength deflation | Results: "shows clearly" → Discussion: "appears to indicate" |
| Characterisation change | Results: "coverage-expanding" → Conclusion: "quality-improving" |
| Number mismatch | Results: "approximately 70 models" → Conclusion: "over 80 models" |
| Missing qualification | Results: "with limitations X, Y" → Conclusion: repeats finding without limitations |

### 7.3 Parallel Structure in Repeated Patterns

When the document discusses multiple items of the same type (e.g., multiple meta-requirements, multiple experiments, multiple datasets), each should be presented with the same structural pattern.

**What to check:**
- If MR1 is presented with "[definition], [which DP addresses it], [evidence]", then MR2–MR6 should follow the same pattern
- If Dataset A results include "[metric table], [interpretation paragraph], [limitation note]", then Dataset B results should too
- If Chapter 4 opens with a diagram and process description, Chapter 5 should open similarly if it covers a parallel pipeline stage

### 7.4 Forward References and Promises

Track every promise or forward reference in the document and verify it is fulfilled:

| Promise type | How to find | What to verify |
|-------------|-------------|---------------|
| Explicit forward ref | "as discussed in Section X" / "Chapter Y presents..." | Does Section X / Chapter Y actually contain this? |
| Implicit promise | "This will be evaluated in..." | Is the evaluation actually there? |
| Research question promise | "SRQ3 asks whether..." | Is SRQ3 answered in the conclusion? |
| Methodology promise | "We evaluate using [method]" | Is [method] actually used in results? |

```bash
# Find forward references
grep -n 'will be\|is discussed in\|is presented in\|as shown in\|see Section\|see Chapter' [files]
```

### 7.5 Backward References and Grounding

Every major claim in Discussion and Conclusion should be grounded in a specific result from the Results chapter. Check:

- Does every discussion point reference a specific section/figure/table from Results?
- Does the conclusion cite specific evidence or speak in generalities?
- Are there discussion points that have no corresponding result?

### 7.6 Introduction–Conclusion Mirror

The Introduction and Conclusion should mirror each other:

| Introduction says | Conclusion should say |
|------------------|----------------------|
| "The problem is X" | "We addressed X by..." |
| "The research question is Y" | "The answer to Y is..." |
| "We use methodology Z" | "Using Z, we found..." |
| "This thesis contributes A, B, C" | "The contributions are A (validated by...), B (shown in...), C (demonstrated through...)" |

**Check the exact wording of the research question in both places.** It must be identical, not paraphrased. A paraphrased RQ in the conclusion is a common and easily caught inconsistency.

### 7.7 Consistent Chapter Framing

If similar chapters frame their contribution differently, it creates a disjointed reading experience.

| Check | Example |
|-------|---------|
| "This chapter describes..." vs "In this section, we present..." | Tonal framing inconsistency |
| One results section frames positively ("achieves 85%"), another frames negatively for equivalent quality ("only reaches 85%") | Evaluative framing inconsistency |
| One limitation is described as "future work", another equivalent limitation is described as a "threat to validity" | Categorisation inconsistency |

## Report Format

```
NARRATIVE FINDINGS
==================

🧵 RED THREAD GAPS:
  [N]. Chapter [X] does not reference the research question or central problem
    Section: [section name]
    Issue: [description]

🧵 CLAIM INCONSISTENCIES:
  [N]. "[claim A]" in [file:line] vs "[claim B]" in [file:line]
    Type: [strength/characterisation/number mismatch]
    Recommendation: [which version is correct]

🧵 BROKEN PROMISES:
  [N]. "[promise]" in [file:line] — not fulfilled in [expected location]

🧵 UNGROUNDED DISCUSSION POINTS:
  [N]. Discussion point in [file:line] has no corresponding result

🧵 INTRO–CONCLUSION MISMATCH:
  [N]. RQ in introduction: "[wording A]"
       RQ in conclusion: "[wording B]"
       Difference: [what changed]

🧵 PARALLEL STRUCTURE BREAKS:
  [N]. [item type] presented differently: [pattern A] vs [pattern B]
```
