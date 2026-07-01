# PR inventory — `<source>` → `<target>`

Working ledger for the `mapping-prs-to-migration-issues` skill. One row per merged
**source** PR. Fill `folders` from `gh pr diff <n> --repo <source> --name-only`
(reduced to top-level dirs) and `→ epic` as you cluster. Every PR must end with an
epic number, `MISSING`, or `N/A` — nothing left blank.

| PR | folders | description-short | theme | → epic |
|---|---|---|---|---|
| [#3](https://github.com/<source>/pull/3) | `ops/`, `satellite/main` | Parameterize station user + root via env | config | #7 |
| [#6](https://github.com/<source>/pull/6) | `daemon/`, `ops/` | Fix Linux traffic lights + image-paste chip | linux-station | #5 (+#6) |
| [#9](https://github.com/<source>/pull/9) | `satellite/{main,renderer,preload}` | Cmd+click file-viewer popup | file-viewer | #1 |
| [#25](https://github.com/<source>/pull/25) | root | Combine the repos | meta | N/A |
| [#<n>](https://github.com/<source>/pull/<n>) | … | … | … | MISSING |

- **folders** — the top-level dirs the PR touched (this scopes the port; the porter reads it first).
- **theme** — the feature area, used to cluster PRs into epics.
- **→ epic** — the target epic that incorporates it · `MISSING` (gap → create an epic) · `N/A`
  (meta/merge, nothing to port). `(+#n)` = also touches epic n.

> Tip: this ledger is scratch/working state — it lives in the migration's own notes, not necessarily
> committed. The committed source of truth is the **INDEX issue** (`index-issue.template.md`).
