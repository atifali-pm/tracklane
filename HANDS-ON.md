# Tracklane — Hands-on Build Guide

This is the engineering-side companion to the product-facing `README.md`. If you are starting a Claude Code session in this directory, read this first.

## Preflight check

Before starting any build session:

1. Read the full spec at `~/.claude/projects/-home-atif-projects-tracklane/memory/project_tracklane.md`
2. Confirm you are on the latest main branch: `git status`
3. Confirm no port conflicts: `lsof -i :8020 -i :5460` should return nothing
4. Confirm Ruby version: `ruby -v` should show 3.3.x or later
5. Confirm Rails version: `rails -v` should show 8.x
6. Confirm PostgreSQL is running with pgvector: `psql -c "SELECT extname FROM pg_extension;" | grep vector`

## Paste-ready kickoff prompt

Copy this into a new Claude Code session in this directory when starting Phase 1:

```
I am starting Phase 1 of Tracklane per the spec in
~/.claude/projects/-home-atif-projects-tracklane/memory/project_tracklane.md.

Goal: Rails 8 skeleton with native auth, Organizations, Memberships,
and Postgres Row-Level Security scaffold.

Constraints:
- Rails 8 native authentication (not Devise)
- Postgres 16 with pgvector extension
- Solid Queue, Solid Cable, Solid Cache (no Redis)
- Tailwind CSS via cssbundling-rails
- Hotwire (Turbo + Stimulus) already included in Rails 8
- Propshaft for assets
- Port 8020 for web, 5460 for Postgres

Deliverables:
1. rails new tracklane --database=postgresql --css=tailwind
2. Generate User model (native Rails 8 auth)
3. Generate Organization model with slug-based identification
4. Generate Membership model (user <-> organization with role enum: admin, manager, member, viewer)
5. Enable pgvector extension in a migration
6. Write RLS policy for any organization-scoped table as a pattern template
7. Seed: 2 organizations, 2 users with different memberships

Do NOT add AI features in Phase 1. Save that for Phase 6.
Do NOT push to GitHub yet; keep local until Phase 5 ships.
```

## Build plan at a glance

| Phase | Deliverable | Target |
|---|---|---|
| 1 | Rails 8 skeleton + auth + Organizations + RLS scaffold | Weekend 1 |
| 2 | Projects + roles + invitations | Weekend 2 |
| 3 | Issues CRUD + comments + mentions | Weekend 3 |
| 4 | Kanban board + real-time | Weekend 4 |
| 5 | Activity feed + notifications | Weekend 5 |
| 6 | Claude-powered issue triage | Weekend 6 |
| 7 | Ask your project RAG chat | Weekend 7 |
| 8 | Daily team digest | Weekend 8 |
| 9 | Meeting to tickets | Weekend 9 |
| 10 | Gantt + time tracking + wiki | Weekend 10 |
| 11 | HMAC-signed outbound webhooks | Weekend 11 |
| 12 | Kamal 2 deploy + screenshots + README polish | Weekend 12 |

## Known gotchas

- **Rails 8 auth is new.** Uses `has_secure_password` with built-in `Authentication` concern. Not Devise.
- **Solid Queue replaces Sidekiq.** No Redis. Job config lives in `config/queue.yml`.
- **Solid Cable replaces Redis-backed ActionCable.** Configure in `config/cable.yml`.
- **RLS in Rails needs raw SQL.** Use migrations with `execute` for `CREATE POLICY` statements; Rails does not have native RLS DSL.
- **pgvector extension.** Install via `CREATE EXTENSION vector;` in a migration. Use `neighbor` gem for Rails integration.
- **Kamal 2 deploy.** `kamal setup` expects SSH access to the target server and a Docker registry credential.

## Git hygiene

- **NEVER add `Co-Authored-By` or any AI attribution to commits.** See `feedback_no_coauthor.md` in memory.
- Clean imperative commit messages: "add organization model", "implement RLS scaffold"
- Separate commits per logical deliverable within a phase
- Do not push to GitHub until Phase 5 ships with a working demo

## Decision log

Keep decisions log here as the build progresses:

- `2026-04-22` — Project spec committed. Name placeholder: Tracklane. Stack locked: Rails 8, Postgres 16, Solid Queue/Cable/Cache, Hotwire, Tailwind, Kamal 2. MIT license. Ports 8020/5460.
- `2026-04-22` — Phase 1 landed. Toolchain: mise + Ruby 3.3.11, Rails 8.1.3, neighbor gem for pgvector. Postgres 16 + pgvector via `docker-compose.yml` on port 5460. Generated native auth (User, Session, Current), Organization + Membership models, pgvector extension migration, RLS scaffold migration (`apply_tenant_rls` helper applied to `memberships`). Dashboard at `/` verifies end-to-end login with seeded alice@tracklane.dev / password.

## Phase 1 follow-ups

The RLS policy is in place but does not enforce yet: the `tracklane` dev role in Postgres is a superuser (Docker default), and superusers bypass RLS even with `FORCE ROW LEVEL SECURITY`. Before writing the 20+ cross-tenant integration tests from the spec:

1. Split Postgres roles: introduce `tracklane_app` (NOSUPERUSER NOBYPASSRLS) in a Compose init script; Rails connects as that role while migrations run as `tracklane`.
2. Add `TenantScoping` concern in `ApplicationController` that sets `SET LOCAL app.current_organization_id = <id>` per request.
3. Extend RLS to every tenant-scoped table added in later phases (call `apply_tenant_rls(:table)` in its own migration).
4. Write the isolation test suite (pattern from StoreBridge's 16-assertion suite).

## Related docs

- Product-facing: `README.md` in this directory
- Full spec: `~/.claude/projects/-home-atif-projects-tracklane/memory/project_tracklane.md`
- Self-hosting guide (future): `docs/DEPLOY.md`
- Feedback rules: all `feedback_*.md` files in the memory directory
