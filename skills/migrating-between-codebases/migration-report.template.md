# Migration report — <source> → <target> (<date>)

The audit trail of what was ported and **why**. This is where migration
narrative belongs — keep it OUT of the code comments.

## Ledger

| Unit (folder / file) | State | Decision | Why | Verified |
|---|---|---|---|---|
| `satellite/main/search-*` | source-only | copy | new feature, self-contained | build + tests ✓ |
| `daemon/internal/config` | diverged | keep-target | target had the later fix | n/a |
| `ops/mount-watchdog.sh` | diverged | merge | source logic + target error handling | tests ✓ |
| `satellite/renderer/tts/*` | source-only | copy | new feature | tests ✓ |
| `<unit>` | … | … | … | … |

- **State:** `source-only` · `target-only` · `identical` · `diverged`
- **Decision:** `copy` · `keep-target` · `take-source` · `merge` · `split` · `skip`

## Dependencies added
- `<package@version>` — why

## Personal data scrubbed
- `<pattern>` → removed from `<files>`
- secret scan: `<tool>` — clean ✓

## Deferred / open gaps
- `<unit>` — not ported yet because …
- `<decision>` — needs a human call
