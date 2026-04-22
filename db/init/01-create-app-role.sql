-- Runs on first volume init only. Creates the limited app role that Rails
-- connects as at runtime (NOSUPERUSER NOBYPASSRLS so RLS enforces).
--
-- Grants are handled by the GrantAppRoleDml migration, not here, because
-- ALTER DEFAULT PRIVILEGES is per-database and does not survive DROP DATABASE.
-- The migration re-applies grants on every db:migrate, which is the only
-- place that guarantees they persist across dev resets.
--
-- The owner role (`tracklane`, set via POSTGRES_USER) is created by the
-- Postgres image itself; this script only adds the app role.

CREATE ROLE tracklane_app LOGIN PASSWORD 'tracklane_app' NOSUPERUSER NOBYPASSRLS;
