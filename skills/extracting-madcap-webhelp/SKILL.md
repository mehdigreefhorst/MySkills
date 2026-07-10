---
name: extracting-madcap-webhelp
description: Use when scraping or extracting a MadCap Flare HTML5 webhelp site into markdown or a RAG/knowledge-base corpus — recognisable by a default.htm TriPane viewer, data-mc-* HTML attributes, Data/*.js chunk files, or an F1/context-sensitive help portal (e.g. product webhelp like webhelp.multivers.nl).
---

# Extracting MadCap Flare Webhelp

## Overview

MadCap Flare webhelp (TargetType "WebHelp2"/TriPane) ships its **entire structure as machine-readable build artifacts**. Never crawl rendered pages to discover content — the build manifest enumerates every topic, the TOC data yields every breadcrumb, and `Alias.xml` maps F1 context IDs to topics. Crawling misses popup-only topics and wastes requests; the data files are complete by construction.

**Recognise the format:** `<html data-mc-runtime-file-type="Default;TriPane">` on default.htm, topic pages with `data-mc-*` attributes, `Skins/`, `Resources/Scripts/MadCapAll.js`.

## Quick reference — the data files (all under the help root)

| File | Gives you |
|---|---|
| `Data/HelpSystem.xml` | **Master manifest**: paths to Toc, Index, Glossary, BrowseSequence, Alias, Search DB; default topic; build version/date; language. Fetch this FIRST. |
| `Data/SearchTopic_Chunk{i}.js` | **Complete topic list** with url, title, abstract per topic. The most complete enumeration (includes popup-only topics absent from the TOC). Chunk count = length of the `t:` offsets array in `Data/Search.js`; or loop i=0,1,2… until 404. |
| `Data/SearchUrl_Chunk{i}.js` | url → topic-id map (lighter alternative enumeration). |
| `Data/Tocs/<Name>.js` (path from manifest) + `<Name>_Chunk{i}.js` | **Hierarchy**: master has `numchunks`, `prefix`, and `tree` of `{i: entryIdx, c: chunkIdx, n: children}`; chunks map `/Content/...htm` → `{i:[ids], t:[titles]}`. Walk tree, invert chunks → breadcrumb per topic. |
| `Data/Alias.xml` | **F1 context map**: `<Map Name="screen_id" Link="Folder/topic.htm" ResolvedId="7020">` — which product screen opens which topic. Keep BOTH fields: the numeric `ResolvedId` is the `#cshid=<id>` value the application actually sends (manifest `IncludeCSHRuntime="true"`); `Link` is relative to `Content/`. Gold metadata for support KBs — also emit a standalone `f1_map.json`. |
| `Data/BrowseSequences/<Name>.js` | Second hierarchy (e.g. by process), same format as Tocs. |
| `Data/Glossary.js`, `Data/Index.js`, `Data/Concepts.js` | Glossary terms, keyword index, concept links (same chunk pattern). |

## Extraction recipe

1. `GET Data/HelpSystem.xml` → record all data-file paths + build metadata.
2. Enumerate topics from `SearchTopic_Chunk*.js`; cross-check with TOC chunk keys and browse-sequence keys; union, normalised to `Content/...` paths (SearchTopic urls are `../Content/...`, TOC keys are `/Content/...`).
3. Build breadcrumbs: walk the TOC `tree` depth-first accumulating titles; resolve each node via inverted chunk maps (`chunkstart` in the master tells which chunk a path belongs to — use it as a free consistency check). Topics not in any tree: fall back to the `Content/` folder path segments (they mirror TOC sections) and flag `breadcrumb_source: fallback`; report the fallback percentage.
4. Fetch every topic (rate-limit ≥0.25s; cache raw HTML to disk so re-runs are free; set a descriptive User-Agent).
5. Parse each topic (next section), download its images, write markdown + frontmatter.
6. **Multi-edition sites**: products often publish sibling editions (`.../12.3.1/Product XL/`, `.../12.3.1/Product Accounting/`) that overlap 90%+. Extract each edition, dedupe by identical `Content/` path + body hash; record which editions share each topic rather than storing copies.
7. Reconcile: enumerated == fetched == parsed, misses listed by URL. Fail loudly on drift.

## Parsing a topic page

Body = `<div id="mc-main-content" role="main">`. Handle these constructs:

| Construct | Treatment |
|---|---|
| `MadCap:conditionalText data-mc-conditions="Primary.F_XL"` | Keep the text; record the condition (it encodes edition variants). |
| `data-mc-conditions` as an ATTRIBUTE on ordinary `<p>`/`<li>` | Same treatment — whole paragraphs/list items are gated (e.g. `Primary.S`, `Primary.XS` = package-size variants). Don't only look for the `MadCap:conditionalText` element. |
| `span.MCExpanding` glossary terms | The definition is inline in `span.MCExpandingBody` — unwrap to "term (definition)" or a footnote. Don't drop it. |
| `MCHelpControl-Related` / `MCHelpControl-Concept` links | The full link list is inline in the anchor's `data-mc-topics` attribute (`title\|href\|\|title\|href…`) — parse it into frontmatter `related:`; remove the `javascript:void(0)` anchor from the body. |
| Boilerplate | Strip `p.MCWebHelpFramesetLink` ("Open onderwerp met navigatie"), `<a name="kanchor…/aanchor…">` index anchors, and empty decorative footer tables. |
| `a.MCTopicPopup` | Popup topic link — keep as a normal link to the target topic (it IS in your topic list). |
| `img src=".../transparent.gif"` | Skin spacer — drop. |
| Callout icons (`Let_Op*`, `Tip*`, `Waarschuwing*` in the src) | Convert the containing block to an admonition (`> **Let op:** …`). |
| Cross-topic `<a href>` | Rewrite to corpus-relative paths. |

**Images — classify by rendered size + subfolder, NOT by path root.** Icon folders and screenshot folders both use the `*-i/` naming, and a `*-i/` folder can be shared by many topics — path alone misleads.
- **Skin/spacer** (`Skins/**`, `transparent.gif`): drop.
- **UI/button icons** — small rendered size (`width`/`height` attrs ≤ ~64px, or `_58x62`-style dimension suffixes in the filename), or icon subfolders (`Knoppen*`, `Helpfile/`, `Opdrachtknoppen*`, `Modulesymbolen*`): replace inline with `` `[knop: <alt or filename>]` `` and map each icon's meaning ONCE in a corpus-level icon table. Do not re-describe per occurrence.
- **Topic screenshots** — larger images, often `class="border"`, in `*-i/` sibling folders: download, reference at original position with alt text, list in frontmatter — these are the ones worth AI-describing later.

## Output contract (chunking-ready)

```
corpus/<edition>/<Content-path>.md   # one file per topic
corpus/<edition>/images/...          # mirrored tree, screenshots only
corpus/icons.md                      # shared icon → meaning table
corpus/f1_map.json                   # F1 name → {resolved_id, topic, editions}
corpus/manifest.json                 # counts, editions, misses, build metadata
raw-cache/                           # untouched HTML, never re-fetch
```

Frontmatter per topic: `url`, `title`, `breadcrumb` (` › `-joined), `breadcrumb_source` (toc|browse|fallback), `edition(s)`, `product_version` (from the URL/manifest), `f1_context` (name + resolved_id pairs from Alias.xml), `related` (from `data-mc-topics`), `conditions` (observed `Primary.*` values), `abstract` (from SearchTopic chunk), `images` (path + alt), `fetched_at`, `build_version`. Chunkers split on headings; the frontmatter travels with every chunk.

## Traps (each cost real time)

| Trap | Reality |
|---|---|
| `Data/Search.js` looks like the topic list | It's the search-engine config/featured-snippets DB. Topic list lives in `SearchTopic_Chunk*` / `SearchUrl_Chunk*`. |
| Soft 404s | Error pages return with content; check HTTP status, not body presence. `Data/Toc.xml`, `Sitemap.xml` don't exist in WebHelp2. |
| Non-breaking spaces in filenames | `Multivers XL.htm` may be `Multivers XL.htm` → encode as `%C2%A0`, not `%20`. Read hrefs raw (`&#160;`), don't retype them. |
| `define({...})` payloads | JavaScript, not JSON: unquoted keys, `'` escapes, trailing commas. Use a JSON5-tolerant parser or targeted regex — `json.loads` will fail. |
| `data-mc-toc-path` on topic pages | Present on some topics, empty/absent on others. Never rely on it — reconstruct breadcrumbs from TOC data. |
| Spaces/apostrophes in topic URLs | Percent-encode when fetching (`Menu's-i/`, `Werken met het Lint.htm`). |
| Directory listing 403 | Normal — the host blocks listing while serving every file. Not a scrape blocker. |
| Same letter, different meaning | `t:` = chunk offsets in `Search.js`, but titles in TOC chunks. Read each file's own shape. |
| Broken authoring paths in `img src` | Published topics can reference the author's DISK layout (`../../../<project-folder>/...image002.gif`, backslash separators included) — resolves outside the help root, 404s live too. Detect (resolved path escapes `Content/`), replace with an "image unavailable" marker, report as a miss; never fetch. Also: URL-derived cache filenames can exceed the 255-byte filesystem limit — hash-bound them. |
| Landing pages without `mc-main-content` | Edition start screens can be `<MadCap:bodyProxy/>` stubs. Fall back to `<body>` + boilerplate stripping instead of failing the topic. |

## Verification checklist

- [ ] Topic count from SearchTopic chunks matches manifest expectations (last chunk + 1 = topic id max; next chunk 404s)
- [ ] enumerated == fetched == parsed in manifest.json; misses explicitly listed
- [ ] Breadcrumb coverage reported (what % from TOC vs fallback)
- [ ] Alias.xml F1 ids attached to their topics
- [ ] A spot-checked topic renders faithfully: tables intact, glossary definitions present, screenshots referenced at correct positions, no `javascript:void(0)` links left
