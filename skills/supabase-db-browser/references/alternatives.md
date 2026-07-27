# Lighter alternatives to Studio

Supabase Studio is the heaviest option here. If the user only wants to see and
edit a schema, offer these first — memory figures are measured idle against a
small Postgres 16 database, not vendor claims.

| Tool | Image | Port | Idle RAM | Notes |
|---|---|---|---|---|
| **pgweb** | `sosedoff/pgweb` | 8081 | **9 MiB** | No login, opens straight into the schema. Browsing + queries; weakest at editing. |
| **Adminer** | `adminer:5` | 8080 | **27 MiB** | One PHP file. Full DDL and DML — every row/column operation. Dated UI, unbeatable weight. |
| **DbGate** | `dbgate/dbgate` | 3000 | 77 MiB | Modern, multi-database, connection seeded from env. Good default choice. |
| **CloudBeaver** | `dbeaver/cloudbeaver` | 8978 | 258 MiB | DBeaver in the browser. First-run wizard; the admin password set via `CB_ADMIN_PASSWORD` is only the *initial* value and is overridden once the wizard runs (it then lives in an H2 DB inside the volume). |
| **pgAdmin 4** | `dpage/pgadmin4` | 80 | 262 MiB | The reference tool. Rejects reserved TLDs in `PGADMIN_DEFAULT_EMAIL` — `admin@local.test` fails to boot, use a real TLD. |
| **Supabase Studio** | see SKILL.md | 3000 | 347 MiB | Only if they specifically want this UI. |

Native apps, if a container is not required: **TablePlus** and **Postico 2**
(macOS, nicer than anything above), **DBeaver** desktop, **Beekeeper Studio**.

## Connection-seeding env vars

```yaml
pgweb:    PGWEB_DATABASE_URL: postgres://u:p@host:5432/db?sslmode=disable
adminer:  ADMINER_DEFAULT_SERVER: <host>        # still prompts for credentials
dbgate:   CONNECTIONS: main
          SERVER_main / PORT_main / USER_main / PASSWORD_main / DATABASE_main
          ENGINE_main: postgres@dbgate-plugin-postgres
pgadmin:  mount servers.json at /pgadmin4/servers.json (password still prompted)
```

## Do not reach for these

**Directus** creates `directus_*` tables in the target database. **NocoDB** is a
platform rather than a client and can write its own metadata. Both are fine
products, wrong tool for "let me look at my database" — every option in the
table above is a pure SQL client that only runs what you ask it to.

If the user wants the spreadsheet feel anyway, say plainly that it will write
to their database first.
