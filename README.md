# MySkills
The claude coding skills that everyone needs.

Each skill lives in `skills/<name>/` with a `SKILL.md` (plus any templates).
Drop a skill folder into your agent's skills directory (e.g. `~/.claude/skills/`)
to use it.

## Skills

| Skill | Use when |
|---|---|
| [migrating-between-codebases](skills/migrating-between-codebases/SKILL.md) | Porting features/fixes between two forks/copies of the same project where a normal `git merge` won't work (no shared history) — reconcile diverged code (adopt/merge/discard), scrub personal data, strip migration cruft, keep real docstrings. |
