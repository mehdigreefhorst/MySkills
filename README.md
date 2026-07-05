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
