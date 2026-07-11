# MySkills
The claude coding skills that everyone needs.

Each skill lives in `skills/<name>/` with a `SKILL.md` (plus any templates).
Drop a skill folder into your agent's skills directory (e.g. `~/.claude/skills/`)
to use it.

## Skills

| Skill | Use when |
|---|---|
| [issue-driven-git-workflow](skills/issue-driven-git-workflow/SKILL.md) | Starting or shipping any feature/bug/enhancement in a git repo — file an issue first, branch off main, commit continuously in logical steps, open a PR that closes the issue, and keep PRs independent (least-conflict next branch when several are open). |
| [migrating-between-codebases](skills/migrating-between-codebases/SKILL.md) | Porting features/fixes between two forks/copies of the same project where a normal `git merge` won't work (no shared history) — reconcile diverged code (adopt/merge/discard), scrub personal data, strip migration cruft, keep real docstrings. |
| [mapping-prs-to-migration-issues](skills/mapping-prs-to-migration-issues/SKILL.md) | Standing up a migration between two GitHub repos and you need a trackable backlog BEFORE porting code — turn the source repo's merged-PR history into grouped epic issues plus one INDEX issue mapping every PR → its epic (covered / MISSING / N/A). |
| [document-consistency-audit](skills/document-consistency-audit/SKILL.md) | Auditing a multi-file document (thesis, report, book, docs) for consistency across nine domains — terminology, formatting, tone/voice, structure, figures & tables, citations, narrative flow, math notation, figure style. Works with LaTeX, Markdown, plain text, reST. |
| [extracting-madcap-webhelp](skills/extracting-madcap-webhelp/SKILL.md) | Scraping/extracting a MadCap Flare HTML5 webhelp site (default.htm TriPane viewer, `data-mc-*` attributes, `Data/*.js` chunk files, F1/context-sensitive help portals) into markdown or a RAG/knowledge-base corpus — full topic enumeration from build data files, breadcrumbs, F1 context mapping, image handling, chunking-ready output. |
