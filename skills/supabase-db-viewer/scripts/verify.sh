#!/usr/bin/env bash
#
# Verify a supabase-db-viewer deployment actually reads the target database.
# "Container is up" is not evidence: Studio serves HTTP 200 with a broken
# postgres-meta behind it. This asserts on real schema rows.
#
# Usage: verify.sh [PORT]   (default 8087)
#
set -uo pipefail

PORT="${1:-8087}"
BASE="http://localhost:${PORT}"
fail=0

pass() { printf '  PASS  %s\n' "$*"; }
bad()  { printf '  FAIL  %s\n' "$*"; fail=1; }

# Studio boots in ~10-30s; retry rather than sleeping a fixed amount.
code="$(curl -s -o /dev/null -w '%{http_code}' -L \
        --retry 20 --retry-delay 3 --retry-all-errors -m 180 "$BASE/" 2>/dev/null)"
if [ "$code" = "200" ]; then pass "Studio responding on $BASE"
else bad "Studio returned HTTP $code on $BASE"; fi

body="$(curl -s -m 30 "$BASE/api/platform/pg-meta/default/tables" 2>/dev/null)"
count="$(printf '%s' "$body" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print(-1); raise SystemExit
print(len(d) if isinstance(d, list) else -1)
" 2>/dev/null || echo -1)"

if [ "$count" -gt 0 ] 2>/dev/null; then
  pass "postgres-meta returned $count tables through Studio"
  printf '%s' "$body" | python3 -c "
import sys, json
d = json.load(sys.stdin)
names = [f\"{t['schema']}.{t['name']}\" for t in d[:8]]
print('        ' + ', '.join(names) + (' ...' if len(d) > 8 else ''))
" 2>/dev/null
elif [ "$count" = "0" ]; then
  bad "postgres-meta reachable but returned 0 tables — wrong database, or the schema is empty"
else
  bad "could not read tables through Studio: $(printf '%s' "$body" | head -c 120)"
fi

if [ -f .env ] && grep -q '^MIGRATIONS_DIR=' .env 2>/dev/null; then
  f="$(curl -s -m 25 "$BASE/api/platform/projects/default/content/folders" 2>/dev/null \
       | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)['data']['folders']
except Exception:
    print(''); raise SystemExit
print(next((x['id'] for x in d if x['name'] == 'migrations'), ''))
" 2>/dev/null)"
  if [ -n "$f" ]; then
    n="$(curl -s -m 25 "$BASE/api/platform/projects/default/content/folders/$f" 2>/dev/null \
         | python3 -c "
import sys, json
try:
    print(len(json.load(sys.stdin)['data']['contents']))
except Exception:
    print(0)
" 2>/dev/null)"
    [ "${n:-0}" -gt 0 ] 2>/dev/null \
      && pass "migrations folder visible in the SQL editor ($n files)" \
      || bad "migrations folder present but empty"
  else
    bad "migrations mounted but no 'migrations' folder in the SQL editor"
  fi
fi

echo
if [ "$fail" -eq 0 ]; then
  cat <<EOF
Ready: $BASE

  Real     Table Editor, SQL Editor, Database section
  Broken   Auth, Storage, API docs, Realtime, Edge Functions, Logs
  FAKE     Settings/Infrastructure pages return hardcoded stubs. The pooling
           page claims pgbouncer on port 6543; no pooler exists here. Do not
           copy connection strings from those pages.

  Studio connects as '$(grep -E '^PG_USER=' .env 2>/dev/null | cut -d= -f2-)',
  which owns the database and can drop tables. Use a read-only role if this is
  only for viewing.
EOF
else
  echo "Verification failed. Logs:  docker compose logs studio meta --tail=40"
fi
exit "$fail"
