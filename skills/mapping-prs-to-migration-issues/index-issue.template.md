<!--
Body for the target-repo INDEX issue — the single source of truth for the migration.
Title (set separately):  📋 INDEX — <source> PRs → <target> epics (migration tracker)
Labels:                  epic   (or a dedicated `index` / `tracker` label)
Create with:             gh issue create --repo <target> --title "..." --label epic --body-file <this>
-->

**Purpose:** single source of truth tracking every PR ever merged into **`<source>`** and which
**`<target>`** epic incorporates it. Rows marked ❌ **MISSING** are gaps not yet covered by any epic —
expand the list as you close them.

**Coverage:** `<N>` merged source PRs → `<C>` covered by epics, **`<M>` MISSING**, `<K>` meta/merge (N/A).

| Source PR | description-short | folders | incorporated by |
|---|---|---|---|
| [#3](https://github.com/<source>/pull/3) | Parameterize station user + root via env | `ops/`, `satellite/main` | #7 (+#9) |
| [#9](https://github.com/<source>/pull/9) | Cmd+click file-viewer popup | `satellite/{main,renderer,preload}` | #1 |
| [#25](https://github.com/<source>/pull/25) | Combine the repos | root | — meta/merge (N/A) |
| [#<n>](https://github.com/<source>/pull/<n>) | <desc> | <folders> | ❌ **MISSING** |

### Legend
- **incorporated by** = the `<target>` epic that ports this PR's work. `(+#n)` = also touches epic n.
- ❌ **MISSING** = no epic covers this yet → candidate for a new issue.
- **N/A** = meta/merge commit, nothing to port.

### Newly tracked (were uncovered)
- **#<epic>** ← `<source>#<pr>` (`<what it adds>`)

### Epics
#1 #2 #3 …   <!-- the created epic issue numbers, kept in sync as MISSING rows become epics -->
