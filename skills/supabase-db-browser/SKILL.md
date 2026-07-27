---
name: supabase-db-browser
description: Attach Supabase Studio's table editor to any existing Postgres database as a read/edit GUI, using only studio + postgres-meta (2 containers, ~350 MiB) instead of the full 13-container self-hosted stack. Use when someone wants to browse or edit a project's schema and rows without adopting Supabase.
origin: local
---

# Supabase Studio as a standalone Postgres browser

Supabase's table editor does not talk to Postgres directly — it talks to
**`postgres-meta`**, a REST API over the Postgres catalog. So the entire
table-editing experience is two containers. Everything else in the self-hosted
stack (Kong, GoTrue, PostgREST, Realtime, Storage, Edge Runtime, Logflare,
Vector, Supavisor) exists to serve the *other* dashboard sections.

| | Containers | Idle RAM |
|---|---|---|
| Full self-hosted stack | 13 | ~2,150 MiB |
| **Browser mode** | **2** | **~350 MiB** |

Works against **vanilla Postgres**. No Supabase extensions, no `auth`/`storage`
schemas, no superuser required — verified against a plain `postgres:16-alpine`.

## When to Activate

- "I just want to see/edit my database" and they like the Supabase UI
- Comparing DB GUIs (see `references/alternatives.md` for lighter options)
- A project already has Postgres and adopting Supabase is not on the table

Do **not** activate when they need auth, storage, realtime, edge functions or
the auto-generated REST API — that needs the full stack.

## Exact procedure

### 1. Discover the target database

Look, in order, for: `.env` / `.env.local`, `docker-compose.yml`, `config.toml`,
`alembic.ini`, `prisma/schema.prisma`. Extract host, port, db, user, password
(often a single `DATABASE_URL` / `POSTGRES_*` set).

### 2. Classify how to reach it — this is the decision that matters

| Situation | `--network` | `--db-host` |
|---|---|---|
| Postgres runs in Docker | its compose network (`docker network ls`) | the **service name**, e.g. `postgres` |
| Postgres on the host | omit | `host.docker.internal` |
| Remote/managed | omit | the real hostname |

Prefer the docker-network path. It needs no published DB port, so it cannot
collide with anything else on 5432 — a real hazard when other Supabase stacks
are around.

### 3. Make sure it is actually running

If it is a stopped container, start **only** that service — never the whole
compose file, which may drag up vector DBs, workers and model downloads:

```bash
docker compose up -d postgres          # add --profile <p> if it has one
```

### 4. Generate and start

```bash
~/.claude/skills/supabase-db-browser/scripts/setup.sh \
  --network myproj_default --db-host postgres --db-name mydb \
  --db-user myuser --db-password "$PW" --port 8087 --dir ./supabase-browser
```

Accepts `--dsn postgresql://user:pass@host:port/db` instead of the discrete
flags. Optional `--migrations /abs/path/to/sql` mounts a folder of `.sql` files
read-only into the SQL editor (see below). Writes `.env` at mode 600, generates
a fresh `CRYPTO_KEY`, starts both containers and verifies.

### 5. Verify — do not trust "container is up"

```bash
~/.claude/skills/supabase-db-browser/scripts/verify.sh 8087
```

Passing means Studio's own API returned real table rows from the target DB.
`setup.sh` runs this automatically and fails loudly if the schema is empty.

## What works and what is a lie

Verified by exercising every operation against a live database:

**Real** — Table Editor, SQL Editor, and the whole Database section. Reads:
schemas, tables, columns, views, materialized views, foreign tables, functions,
triggers, indexes, policies, publications, roles, types, extensions, config.
Writes: create/drop table, insert/select/update/delete rows, add/rename/retype/
drop columns, enable RLS, create policies, create indexes.

**Fails loudly** (backing service absent — fine, you'll notice): Authentication
`fetch failed`, Storage `HTTP 500`, API docs, Realtime, Edge Functions, Logs.

**Fabricated — the actual trap.** Some platform routes return hardcoded stubs
instead of failing:

```
GET /api/platform/database/<ref>/pooling
  → {"db_port":6543,"pool_mode":"transaction","pgbouncer_enabled":true}
```

There is no pooler in browser mode. `/api/platform/organizations` likewise
invents an org with `billing@supabase.co`. **Tell the user: trust Table Editor,
SQL Editor and Database; treat Settings/Infrastructure as decoration.** A
connection string copied from those pages points at a port that does not exist.

## Hiding the fabricated pages

Studio reads `ENABLED_FEATURES_*` env vars at container start — one per flag,
uppercased with non-alphanumerics replaced by `_` (`logs:all` →
`ENABLED_FEATURES_LOGS_ALL`). `setup.sh` switches off 35 by default: billing,
read replicas, replication, network restrictions, custom domains, log drains,
database upgrades, project restart, add-ons, organisation and account settings,
integrations, logs, reports, the auth sub-panels, storage analytics and vectors,
and the edge-function examples. All 35 verified accepted against
`supabase/studio:2026.07.07`, with `/api/enabled-features-overrides` echoing
back exactly what was set.

Pass `--show-all-features` to keep them visible.

Two things to be honest about:

- **No flag exists for the pooling/Connect panel** — the worst offender. It can
  only be documented, not hidden. Same for Authentication, Storage, Realtime and
  Edge Functions as whole sections: the flag list has sub-flags but no
  `authentication:all` or `storage:all`, so those sections still appear and
  still fail. They fail *loudly*, which is the acceptable case.
- **Flags hide features; they do not grey them out with an explanation.**
  Anything more means patching Studio's minified Next.js bundle, which breaks on
  every image bump. Not worth it.

Studio validates these vars and logs unknown ones (`does not match any known
feature; ignoring`), so a flag renamed upstream is noisy rather than silent. If
an image bump produces that warning, re-derive the list from
`packages/common/enabled-features/enabled-features.json` (~101 flags).

## Showing a project's migration files

Studio's snippets folder is just a directory of `.sql` files that it `readdir`s,
deriving deterministic UUIDs from paths. So `--migrations <dir>` surfaces an
existing migrations folder as a read-only folder in the SQL editor — live from
disk, nothing written to the database.

Do **not** wire up Studio's built-in Database → Migrations page. It reads
`supabase_migrations.schema_migrations`, a Supabase-owned schema with a
different shape. Populating it means creating a schema in someone's database
and duplicating rows their own migration runner already owns — two competing
sources of truth, and a table `supabase db push` would later expect to control.
The project's own migrations table is already visible in the Table Editor.

## Gotchas

- **Studio connects as the DB owner** — it can drop tables as easily as read
  them. If viewing is the point, offer a read-only role and point `--db-user`
  at it (`references/read-only-role.sql`).
- **`POSTGRES_USER_READ_WRITE` must be the real DB user.** The upstream compose
  hardcodes `postgres`; most projects do not have that role.
- **`CRYPTO_KEY` / `PG_META_CRYPTO_KEY` must be ≥32 chars** and identical in
  both services.
- **`HOSTNAME: "0.0.0.0"`** or Studio binds loopback inside the container and
  the published port answers nothing.
- **Snippets folder must be writable**, or saved queries vanish on restart.
  Mount migrations as a `:ro` *subfolder*, never as the root.
- **Never use `${VAR:-{"json":[]}}` defaults.** Docker Compose < 2.20 mis-parses
  the braces and appends a stray `}`, producing invalid JSON. This silently
  corrupts JWKS config in the full stack; browser mode avoids brace defaults
  entirely. Check with `docker compose version`.
- **In zsh, unquoted `$var` does not word-split.** `set -- $pair` and
  `cmd $args` behave differently than in bash — quote or use arrays.

## Teardown

```bash
cd <dir> && docker compose down          # add -v to drop the snippets volume
```

Leaves the target database untouched.
