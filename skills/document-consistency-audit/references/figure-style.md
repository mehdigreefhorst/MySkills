# Domain 9: Figure Size & Visual Style Consistency

## What This Domain Covers

All figures should look like they belong to the same document. This means consistent sizing, consistent colour palettes, consistent fonts within figures, consistent borders/frames, and consistent resolution. This domain audits the visual presentation of figures, diagrams, and screenshots at both the LaTeX inclusion level (width, scale, placement) and the visual content level (colours, fonts, style).

## Key Constraint

Figures produced by different tools (matplotlib, draw.io, screenshots, TikZ) will inherently look different. The goal is not to make every figure identical, but to enforce consistency **within figure types** and to flag jarring visual mismatches. Ask the user in Step 0.1 which figures are regenerable and which are fixed.

## Extraction Checklist

### 9.1 Figure Width and Scale Specifications

Every `\includegraphics` call specifies a size. These must be consistent for equivalent figure types.

```bash
# Extract all includegraphics calls with their sizing
grep -Pn '\\includegraphics\s*\[([^\]]*)\]' [files]
```

**Build a size inventory:**

| Figure type | Expected width | What to check |
|-------------|---------------|--------------|
| Full-width single figure | `width=\textwidth` or `width=\linewidth` | Always the same? |
| Half-width subfigure | `width=0.48\textwidth` or similar | All subfigures the same width? |
| Third-width subfigure | `width=0.32\textwidth` | Consistent? |
| Screenshot | Various | Consistent within screenshot type? |
| Diagram | Various | Consistent for similar diagrams? |
| Plot/chart | Various | Consistent for similar plots? |

**What to flag:**

| Issue | Example | Severity |
|-------|---------|----------|
| Same figure type, different widths | BPMN diagrams at `width=0.8\textwidth` in Ch4 but `width=\textwidth` in Ch6 | CONSISTENCY |
| `scale=` vs `width=` mixed | `\includegraphics[scale=0.5]` in one place, `[width=0.7\textwidth]` in another for similar content | CONSISTENCY |
| Inconsistent subfigure sizing | Left subfigure `0.45\textwidth`, right subfigure `0.5\textwidth` in same figure | STYLE |
| `\textwidth` vs `\linewidth` | Mixed usage (functionally identical in most cases, but pick one) | STYLE |
| Hardcoded dimensions | `width=12cm` vs relative `width=0.8\textwidth` | CONSISTENCY |
| No size specified | `\includegraphics{file}` with no width/scale — output depends on image resolution | CONSISTENCY |

```bash
# Categorise sizing approaches
echo "=== width=\textwidth ===" && grep -c 'width=\\textwidth' [files]
echo "=== width=\linewidth ===" && grep -c 'width=\\linewidth' [files]
echo "=== width=0. ===" && grep -oP 'width=0\.\d+' [files] | sort | uniq -c | sort -rn
echo "=== scale= ===" && grep -oP 'scale=[\d.]+' [files] | sort | uniq -c | sort -rn
echo "=== hardcoded cm/in ===" && grep -oP 'width=\d+\.?\d*(cm|in|mm|pt)' [files] | sort | uniq -c
echo "=== no sizing ===" && grep -P '\\includegraphics\{' [files] | grep -v '\[' 
```

### 9.2 Aspect Ratio Consistency

Figures of the same type should have similar aspect ratios. A landscape diagram in one chapter and a portrait diagram of the same type in another is visually jarring.

**What to check:**
- Flowcharts/BPMN diagrams: all landscape or all portrait?
- Screenshots: all from the same viewport width, or some cropped differently?
- Plots: all the same aspect ratio (e.g., 4:3, 16:9, square)?
- Subfigure pairs: both elements the same height?

### 9.3 Colour Palette Consistency

If figures use colour, the palette should be consistent across the document.

**What to check:**
- Do code-generated plots (matplotlib, R) use the same colour scheme?
- Do diagrams use the same colour for the same semantic meaning? (e.g., "green = success" in one figure but "green = category A" in another)
- Are some figures greyscale while others are full colour? (May be intentional for print-friendliness, but should be consistent)
- Do colours match between figures and text emphasis? (e.g., if a figure highlights something in blue, is blue used for the same concept in other figures?)

**For LaTeX-internal figures (TikZ, pgfplots):**
```bash
# Find colour definitions
grep -n '\\definecolor\|\\colorlet\|color=' [files]
# Find colour usage in tikz
grep -Pn 'fill=|draw=|color=' [files] | grep -v '\\definecolor'
```

**For external figures:** This requires visual inspection. Flag any figures the user should review side by side. If figures are code-generated, check the plotting scripts for palette definitions.

### 9.4 Font Consistency Within Figures

Text inside figures (axis labels, annotations, legends, node labels) should use a consistent font that matches or complements the document body font.

**What to flag:**
- Axis labels in sans-serif (matplotlib default) while body text is serif
- Annotation text in a different size across figures
- Some figures have axis labels, others don't
- Legend font size varies between figures
- Node labels in diagrams use different fonts/sizes across chapters

**For TikZ figures:**
```bash
grep -Pn 'font=|\\footnotesize|\\small|\\normalsize|\\large' [files] | grep -i tikz
```

### 9.5 Resolution and File Format

| Format | Best for | Minimum resolution |
|--------|---------|-------------------|
| PDF | Vector graphics (diagrams, plots, flowcharts) | N/A (vector) |
| PNG | Raster graphics (screenshots, photos) | 150 DPI for print, 72 DPI for screen |
| JPG | Photographs only | 150 DPI |
| SVG | Web output only | N/A (vector) |

```bash
# Inventory figure file formats
find figures/ -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn

# Check for low-resolution PNG files (rough heuristic: small file size for large display)
find figures/ -name "*.png" -size -50k -exec echo "POTENTIALLY LOW-RES: {}" \;
```

**What to flag:**
- Vector content (diagrams, flowcharts) saved as PNG instead of PDF — loss of quality at zoom
- Photos saved as PNG instead of JPG — unnecessary file size
- Mixed formats for same figure type (some diagrams as PDF, others as PNG)
- Visibly pixelated figures (check at 200% zoom)

### 9.6 Border, Frame, and Background

| Convention | What to check |
|-----------|--------------|
| Figure borders | Some figures have a border/frame, others don't. Consistent? |
| Background | Some figures have white background, others transparent, others grey. Consistent? |
| Drop shadows | Used on some figures but not others? |
| Padding | Space between figure content and caption consistent? |

### 9.7 Screenshot Consistency

If the document includes screenshots (common in tool-focused theses):

| Convention | What to check |
|-----------|--------------|
| Browser chrome | Some screenshots include browser bar, others crop it out. Consistent? |
| Dark mode / light mode | All screenshots from the same UI theme? |
| Annotation style | Arrows, boxes, highlights — same colour and style across screenshots? |
| Cropping | Consistent amount of surrounding context shown? |
| Resolution / zoom level | All from same screen resolution / zoom level? |

### 9.8 Diagram Style Consistency

If the document includes diagrams (UML, BPMN, flowcharts, architecture diagrams):

| Convention | What to check |
|-----------|--------------|
| Tool consistency | All from the same tool (draw.io, Lucidchart, TikZ) or mixed? |
| Shape style | Rounded vs sharp corners. Consistent? |
| Arrow style | Filled vs open arrowheads. Line thickness. Consistent? |
| Node colouring | Same semantic meaning gets same colour? |
| Label placement | Inside nodes vs outside. Consistent? |
| Grid/alignment | Nodes aligned to grid or free-floating? |

### 9.9 Figure Grouping and Subfigure Layout

| Convention | What to check |
|-----------|--------------|
| Subfigure package | `\subfloat` (subfig) vs `\begin{subfigure}` (subcaption) — one convention only |
| Subcaption style | "(a)" vs "a)" vs "A" — consistent? |
| Spacing | `\hfill`, `\quad`, `\hspace` between subfigures — consistent? |
| Grid layout | 2-column always, or sometimes 3-column? Justified by content or random? |
| Subcaption position | Below subfigure (standard) or above? |

```bash
# Check subfigure conventions
grep -n '\\subfloat\|\\begin{subfigure}' [files]
grep -Pn '\\captionsetup\[subfloat\]' [files]
```

## Report Format

```
FIGURE SIZE & VISUAL STYLE FINDINGS
=====================================

📏 SIZE INCONSISTENCIES:
  [N]. [figure type] at [width A] in [file:line] but [width B] in [file:line]
    Recommendation: standardise to [width]

📏 SCALE METHOD INCONSISTENCIES:
  [N]. `scale=` in [file:line] but `width=` in [file:line] for similar content

🎨 COLOUR PALETTE ISSUES:
  [N]. [description of colour mismatch between figures]
    Figures to review side by side: [fig:A], [fig:B]

🔤 FONT ISSUES WITHIN FIGURES:
  [N]. [description] in [file:line]

🖼️ FORMAT ISSUES:
  [N]. [vector content as raster / wrong format] in [file:line]
    File: [figure path]

🖼️ SCREENSHOT INCONSISTENCIES:
  [N]. [description: chrome visible/hidden, dark/light mode, annotation style]

🖼️ DIAGRAM STYLE MISMATCHES:
  [N]. [description: tool, shape style, arrow style]

🖼️ SUBFIGURE CONVENTION ISSUES:
  [N]. [mixed packages / inconsistent subcaptions]

📝 FIGURES REQUIRING VISUAL REVIEW:
  (These cannot be fully audited by code — user must check)
  [N]. [figure path] — check [specific concern]
```
