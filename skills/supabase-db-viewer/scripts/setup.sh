#!/usr/bin/env bash
#
# Attach Supabase Studio + postgres-meta to an existing Postgres database.
# Generates a compose project, starts it, and verifies Studio can actually read
# the target schema. See ../SKILL.md for the surrounding procedure.
#
set -euo pipefail

STUDIO_IMAGE_DEFAULT="supabase/studio:2026.07.07-sha-a6a04f2"
META_IMAGE_DEFAULT="supabase/postgres-meta:v0.96.6"

DB_HOST=""; DB_PORT="5432"; DB_NAME=""; DB_USER=""; DB_PASSWORD=""
NETWORK=""; PORT="8087"; DIR="./db-viewer"; MIGRATIONS=""; SCHEMAS="public"
PROJECT_LABEL=""; ORG_LABEL="Local"; NAME=""
STUDIO_IMAGE="$STUDIO_IMAGE_DEFAULT"; META_IMAGE="$META_IMAGE_DEFAULT"

die() { printf '\nerror: %s\n' "$*" >&2; exit 1; }
note() { printf '  %s\n' "$*"; }

usage() {
  sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
  cat <<'USAGE'

Usage:
  setup.sh --dsn postgresql://user:pass@host:5432/db [options]
  setup.sh --db-host H --db-name N --db-user U --db-password P [options]

Options:
  --network NAME      docker network the database is on; --db-host is then the
                      compose service name. Omit for a host/remote database.
  --port N            host port for Studio (default 8087)
  --dir PATH          where to write the compose project (default ./db-viewer)
  --migrations PATH   folder of .sql files, mounted read-only into the SQL editor
  --schemas LIST      comma-separated schemas to expose (default public)
  --name SLUG         compose project + container prefix, must be unique per
                      running viewer (default: db-viewer-<dbname>)
  --project NAME      label shown in Studio (default: database name)
  --org NAME          organisation label shown in Studio (default: Local)
  --studio-image REF  override Studio image
  --meta-image REF    override postgres-meta image
USAGE
}

parse_dsn() {
  local dsn="$1" rest userpass hostport
  [[ "$dsn" =~ ^postgres(ql)?:// ]] || die "--dsn must start with postgres:// or postgresql://"
  rest="${dsn#*://}"
  [[ "$rest" == *"@"* ]] || die "--dsn must include user[:password]@"
  userpass="${rest%%@*}"; hostport="${rest#*@}"
  DB_USER="${userpass%%:*}"
  [[ "$userpass" == *":"* ]] && DB_PASSWORD="${userpass#*:}"
  local hp="${hostport%%/*}" path="${hostport#*/}"
  DB_NAME="${path%%\?*}"
  DB_HOST="${hp%%:*}"
  [[ "$hp" == *":"* ]] && DB_PORT="${hp#*:}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dsn) parse_dsn "$2"; shift 2 ;;
    --db-host) DB_HOST="$2"; shift 2 ;;
    --db-port) DB_PORT="$2"; shift 2 ;;
    --db-name) DB_NAME="$2"; shift 2 ;;
    --db-user) DB_USER="$2"; shift 2 ;;
    --db-password) DB_PASSWORD="$2"; shift 2 ;;
    --network) NETWORK="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --dir) DIR="$2"; shift 2 ;;
    --migrations) MIGRATIONS="$2"; shift 2 ;;
    --schemas) SCHEMAS="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --project) PROJECT_LABEL="$2"; shift 2 ;;
    --org) ORG_LABEL="$2"; shift 2 ;;
    --studio-image) STUDIO_IMAGE="$2"; shift 2 ;;
    --meta-image) META_IMAGE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

[ -n "$DB_HOST" ] || die "missing --db-host (or --dsn)"
[ -n "$DB_NAME" ] || die "missing --db-name (or --dsn)"
[ -n "$DB_USER" ] || die "missing --db-user (or --dsn)"
[ -n "$DB_PASSWORD" ] || die "missing --db-password (or --dsn)"
[ -n "$PROJECT_LABEL" ] || PROJECT_LABEL="$DB_NAME"
# Unique per database, so several viewers can run side by side. A fixed name
# makes a second deployment silently recreate the first one's containers.
if [ -z "$NAME" ]; then
  NAME="db-viewer-$(printf '%s' "$DB_NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-' | sed 's/-*$//')"
fi

command -v docker >/dev/null 2>&1 || die "docker not found"
docker info >/dev/null 2>&1 || die "docker daemon not reachable"
command -v openssl >/dev/null 2>&1 || die "openssl not found"

echo "==> checks"
COMPOSE_VER="$(docker compose version --short 2>/dev/null || echo unknown)"
note "docker compose $COMPOSE_VER"

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  die "host port $PORT is already in use — pass a different --port"
fi
note "host port $PORT is free"

if [ -n "$NETWORK" ]; then
  docker network inspect "$NETWORK" >/dev/null 2>&1 \
    || die "docker network '$NETWORK' not found (docker network ls)"
  note "network $NETWORK exists; reaching db at $DB_HOST:$DB_PORT"
else
  note "no --network: reaching db at $DB_HOST:$DB_PORT from the default bridge"
fi

if [ -n "$MIGRATIONS" ]; then
  [ -d "$MIGRATIONS" ] || die "--migrations path is not a directory: $MIGRATIONS"
  case "$MIGRATIONS" in /*) ;; *) MIGRATIONS="$(cd "$MIGRATIONS" && pwd)" ;; esac
  note "migrations folder $MIGRATIONS ($(find "$MIGRATIONS" -maxdepth 1 -name '*.sql' | wc -l | tr -d ' ') .sql files)"
fi

echo "==> writing $DIR"
mkdir -p "$DIR/snippets"
cd "$DIR"

# Secrets live only in .env, never in the compose file.
( umask 077; cat > .env <<EOF
PG_HOST=$DB_HOST
PG_PORT=$DB_PORT
PG_DB=$DB_NAME
PG_USER=$DB_USER
PG_PASSWORD=$DB_PASSWORD
PG_SCHEMAS=$SCHEMAS
PG_META_CRYPTO_KEY=$(openssl rand -base64 24)
STUDIO_PORT=$PORT
STUDIO_IMAGE=$STUDIO_IMAGE
META_IMAGE=$META_IMAGE
ORG_LABEL=$ORG_LABEL
PROJECT_LABEL=$PROJECT_LABEL
EOF
# Must not be an && list: it would be the subshell's exit status, and a false
# test would abort the script under `set -e`.
if [ -n "$MIGRATIONS" ]; then
  echo "MIGRATIONS_DIR=$MIGRATIONS" >> .env
fi
)
chmod 600 .env
note ".env written (mode 600)"

# Conditional fragments.
if [ -n "$NETWORK" ]; then
  NET_TOP=$'networks:\n  target:\n    external: true\n    name: '"$NETWORK"
  NET_SVC=$'    networks: [target]'
  EXTRA_HOSTS=""
else
  NET_TOP=""
  NET_SVC=""
  EXTRA_HOSTS=$'    extra_hosts:\n      - "host.docker.internal:host-gateway"'
fi
MIG_VOL=""
[ -n "$MIGRATIONS" ] && MIG_VOL=$'      - ${MIGRATIONS_DIR}:/app/snippets/migrations:ro'

{
cat <<EOF
# Generated by the supabase-db-viewer skill. Studio + postgres-meta only:
# the table editor, SQL editor and Database section. Everything else in the
# dashboard is absent or stubbed — see the skill's SKILL.md.

name: ${NAME}
EOF
[ -n "$NET_TOP" ] && printf '\n%s\n' "$NET_TOP"
cat <<EOF

services:
  meta:
    image: \${META_IMAGE}
    container_name: ${NAME}-meta
    restart: unless-stopped
EOF
[ -n "$NET_SVC" ] && printf '%s\n' "$NET_SVC"
[ -n "$EXTRA_HOSTS" ] && printf '%s\n' "$EXTRA_HOSTS"
cat <<EOF
    environment:
      PG_META_PORT: 8080
      PG_META_DB_HOST: \${PG_HOST}
      PG_META_DB_PORT: \${PG_PORT}
      PG_META_DB_NAME: \${PG_DB}
      PG_META_DB_USER: \${PG_USER}
      PG_META_DB_PASSWORD: \${PG_PASSWORD}
      CRYPTO_KEY: \${PG_META_CRYPTO_KEY}

  studio:
    image: \${STUDIO_IMAGE}
    container_name: ${NAME}-studio
    restart: unless-stopped
    depends_on: [meta]
    ports: ["\${STUDIO_PORT}:3000"]
EOF
[ -n "$NET_SVC" ] && printf '%s\n' "$NET_SVC"
[ -n "$EXTRA_HOSTS" ] && printf '%s\n' "$EXTRA_HOSTS"
cat <<EOF
    environment:
      # Without this Studio binds loopback inside the container.
      HOSTNAME: "0.0.0.0"
      STUDIO_PG_META_URL: http://meta:8080
      POSTGRES_HOST: \${PG_HOST}
      POSTGRES_PORT: \${PG_PORT}
      POSTGRES_DB: \${PG_DB}
      POSTGRES_PASSWORD: \${PG_PASSWORD}
      # Must be the real owner; upstream hardcodes "postgres".
      POSTGRES_USER_READ_WRITE: \${PG_USER}
      PG_META_CRYPTO_KEY: \${PG_META_CRYPTO_KEY}
      PGRST_DB_SCHEMAS: \${PG_SCHEMAS}
      DEFAULT_ORGANIZATION_NAME: \${ORG_LABEL}
      DEFAULT_PROJECT_NAME: \${PROJECT_LABEL}
      # No gateway here; auth/storage/realtime/functions are expected to fail.
      SUPABASE_URL: http://localhost:9999
      SUPABASE_PUBLIC_URL: http://localhost:\${STUDIO_PORT}
      ENABLED_FEATURES_LOGS_ALL: "false"
      SNIPPETS_MANAGEMENT_FOLDER: /app/snippets
    volumes:
      - ./snippets:/app/snippets
EOF
[ -n "$MIG_VOL" ] && printf '%s\n' "$MIG_VOL"
} > docker-compose.yml
note "docker-compose.yml written (compose project: $NAME)"

echo "==> starting"
docker compose up -d 2>&1 | sed 's/^/  /'

echo "==> verifying"
exec "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")/scripts/verify.sh" "$PORT"
