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
- `2026-04-22` — Phase 2 role split landed. Postgres runs two roles: `tracklane` (owner, runs migrations) and `tracklane_app` (NOSUPERUSER NOBYPASSRLS, what Rails connects as at runtime). Role creation in `db/init/01-create-app-role.sql`; DML grants applied by the `GrantAppRoleDml` migration and re-applied after every `db:migrate / db:schema:load / db:test:prepare` via `lib/tasks/grants.rake`. `schema_format` switched to `:sql` so RLS policies survive in `db/structure.sql`. Run database tasks via `bin/db <task>` (wraps rails with the owner credentials); the regular app connection defaults to `tracklane_app`.
- `2026-04-22` — Phase 2 landed. `TenantScoping` ApplicationController concern wraps every request in a transaction and SETs `app.current_user_id` + `app.current_organization_id` in ordered before_actions so RLS enforces per-request. Split memberships policy (own-rows-or-tenant for SELECT, tenant-only for writes) lets the org switcher see a user's orgs across tenants. `Project` model with CRUD, role-gated via `require_role` helper (admin + manager mutate, others read). `Invitation` model with token-based acceptance, open SELECT policy for token lookups and strict tenant writes. Cross-tenant isolation test suite in `test/integration/tenant_isolation_test.rb` — 25 tests, 50 assertions, all green. Phase 1 RLS follow-ups closed.
- `2026-04-22` — Phase 3 core landed (commit `0a407a3`). `Issue` model with per-project sequential number via `projects.issues_counter` UPDATE ... RETURNING, status + priority enums, optional assignee (validated to be an org member), due_date. `Comment` model denormalizes organization_id for RLS; after_create scans body for `@email@domain` tokens and writes `Mention` rows for org members. IssuesController nested under projects, role-gated (admin+manager any, member own reports, viewer read-only). `IssueTemplate` constants (bug/feature/task) prefill description via `?template=` param. `ProjectTemplate` constants (software/marketing/personal) seed 2 to 4 starter issues on project create via `?template=` param. Isolation suite extended to 51 tests / 121 assertions, all green.
- `2026-04-23` — Phase 4 landed. Kanban board at `/projects/:slug/board` renders 5 columns driven by the `Issue.status` enum. Stimulus `board_controller.js` handles HTML5 drag-drop, PATCHes `/projects/:slug/issues/:number/move`, and reloads on failure. Issue model's `after_update_commit :broadcast_board_update` fires `Turbo::StreamsChannel.broadcast_replace_to [project, :board]` for both source and destination columns, so every subscriber watching `turbo_stream_from [@project, :board]` sees the move within a single polling cycle. Role gate lets admin/manager/member drag; viewer receives `data-board-draggable-value="false"` and the controller strips `draggable` attributes. Dev uses the `async` Action Cable adapter (same-process), production uses `solid_cable` via the cable DB.
- `2026-04-23` — Phase 5 landed (MVP milestone). `ActivityEvent` (polymorphic subject + jsonb metadata, RLS applied) with `ActivityEvent.record!(action, subject:)` central emitter. Events fired from `after_*_commit` on Issue (opened/moved/assigned), Comment (created), Project (created), Membership (created), and Invitation (created). Feed at `/activity` shows org-scoped events, live-updated via `Turbo::StreamsChannel.broadcast_prepend_to [organization, :activity]`. `NotificationMailer` with `mentioned` / `assigned` / `invited` actions delivers via `deliver_later` (Solid Queue in prod, inline in dev). `letter_opener_web` mounted at `/letter_opener` in dev. Because `after_*_commit` fires after the outer request transaction closes (so `SET LOCAL` GUCs are already reset), both `ActivityEvent.record!` and the broadcast callbacks route through `ActivityEvent.with_organization_guc(id)` which save-sets-restores the org GUC to avoid leaking into enclosing transactions (this was caught by the tenant isolation suite). 57 tests / 132 assertions green.

## Phase 3 polish closed 2026-04-23

Dark mode retrofit shipped (commit `a92a233`):

1. ✅ Dark: variants across dashboard, projects, issues, invitations, auth pages, and comments thread.
2. ✅ Inline `prefers-color-scheme` resolver in the layout with CSP nonce support, so `theme=system` flips to light/dark before first paint.

Still optional (not blocking Phase 4): per-organization branding / accent color. If that matters before Phase 5 MVP ships, queue it as a short pre-Phase-4 task; otherwise roll it into the Phase 12 polish pass alongside Kamal + screenshots.

## Phase 1 follow-ups (closed 2026-04-22)

All four items resolved in Phase 2:

1. ✅ Postgres roles split (`tracklane` owner, `tracklane_app` app role).
2. ✅ `TenantScoping` concern sets both user and organization GUCs per request inside a transaction.
3. ✅ `apply_tenant_rls(:table)` helper extracted into `config/initializers/rls_migration_helpers.rb`; invoked by projects and invitations migrations.
4. ✅ Isolation suite in `test/integration/tenant_isolation_test.rb`, 25 tests / 50 assertions.

## Related docs

- Product-facing: `README.md` in this directory
- Full spec: `~/.claude/projects/-home-atif-projects-tracklane/memory/project_tracklane.md`
- Self-hosting guide (future): `docs/DEPLOY.md`
- Feedback rules: all `feedback_*.md` files in the memory directory
