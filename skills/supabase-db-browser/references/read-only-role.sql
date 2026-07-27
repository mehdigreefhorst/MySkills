-- Read-only role for supabase-db-browser.
--
-- By default Studio connects as the database owner and can drop tables as
-- easily as read them. If the point is *viewing*, point --db-user at this role
-- instead: the schema browser and SQL editor keep working, writes are refused
-- by Postgres rather than by the UI.
--
-- Replace <PASSWORD> and adjust the database/schema names.

CREATE ROLE viewer_ro LOGIN PASSWORD '<PASSWORD>';

GRANT CONNECT ON DATABASE <DBNAME> TO viewer_ro;
GRANT USAGE ON SCHEMA public TO viewer_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_ro;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO viewer_ro;

-- Tables created later are not covered by the grants above. This applies only
-- to objects created by the role that runs it, so run it as the owner that
-- your migrations use.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO viewer_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON SEQUENCES TO viewer_ro;

-- Optional: block accidental writes to any *other* schema too.
REVOKE CREATE ON SCHEMA public FROM viewer_ro;

-- Verify (should error with "permission denied"):
--   SET ROLE viewer_ro;
--   CREATE TABLE public.nope (id int);
--   RESET ROLE;

-- Caveats to state out loud:
--  * The Table Editor still renders its insert/edit controls. They fail at
--    execution time with a Postgres permission error rather than being hidden.
--  * postgres-meta reads catalogs only, so the Database section stays fully
--    populated: columns, indexes, policies, triggers, extensions.
--  * A read-only role cannot see other roles' unshared objects; if the schema
--    looks emptier than expected, check ownership before assuming a bug.
