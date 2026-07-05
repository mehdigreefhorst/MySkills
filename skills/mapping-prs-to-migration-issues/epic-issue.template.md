<!--
Body for a target-repo EPIC issue (one feature/theme grouped from source PRs).
Title (set separately):  N. <Area>: <Feature>       e.g. "1. Satellite: File-viewer & Cmd+click linkifier"
Labels:                  epic, <area> (satellite | daemon | ops | ...), <direction> (port-out | port-in)
Create with:             gh issue create --repo <target> --title "..." --label epic --label <area> --label <direction> --body-file <this>
-->

📋 **Implementation plan:** [`<plan-file>.md`](<permalink-into-source>) — detailed, PR-ready steps.
<!-- Optional. A permalink into the SOURCE repo's plan/notes. Omit this line + rule if there's none. -->

---

**Direction:** `port-out` (exists in `<source>` → add to `<target>`)
**Effort:** S | M | L
**Source refs:** <source>#<pr>, <source>#<pr>, …

<One short paragraph: what the feature does in the source, and precisely what the target is missing.>

### Checklist
- [ ] Port main-process modules: `<file>`, `<file>`, …
- [ ] Port renderer/other modules: `<dir>/{<A>,<B>,<C>}`
- [ ] Wire the integration point(s): `<entry>.ts` (`registerX()`), `<boot>.ts`, …
- [ ] Carry the reconciled behavior from `<source>#<pr>` (the resolved fix, not the first attempt)
- [ ] Tests + build green in `<target>`

<!--
Notes:
- Source refs are load-bearing: they tell whoever ports this exactly what to read. Never omit them.
- The checklist is the visible progress bar — list real files/modules, not vague verbs.
- Keep migration narrative OUT of the ported CODE; it belongs here and in the migration report
  (see the `migrating-between-codebases` skill).
-->
