# Tracklane promotion kit

Paste-ready copy + asset references for portfolio site, Fiverr, Upwork, and LinkedIn. Fill the placeholders where marked.

All screenshots live in [public/screenshots](../public/screenshots) and are also accessible on the public GitHub repo.

---

## 1. Portfolio site banner

### Hero

**Headline**
> Tracklane: AI-first project management, self-hostable, built on Rails 8.

**Subhead**
> A multi-tenant PM SaaS I designed and built to show what a 2026 Rails product looks like. 11 of 12 roadmap phases shipped, 79 integration tests green, complete with kanban, timeline, wiki, time tracking, and an optional Claude-powered triage layer.

**Primary CTA button**
> View on GitHub → https://github.com/atifali-pm/tracklane

**Secondary CTA**
> Live demo URL (add once Render deploy lands)

**Hero image**
> `public/screenshots/01-home-dark.png`

### Bullet pitch (for a "What I built" column)

- Multi-tenant from row zero, enforced with Postgres Row-Level Security and a 79-test isolation suite
- Real-time kanban with Stimulus drag-drop and Turbo Streams over Solid Cable
- Project-scoped timeline (Gantt), calendar, workload, and Markdown wiki views
- Claude-powered issue triage and a pgvector-backed "ask your project" chat, both bring-your-own-key so the app stays fully usable when AI is off
- Solid Queue for background jobs, Solid Cache for caching, Kamal 2 ready for deploy
- Dark mode with async toggle, instant Monday-style sidebar + right rail

### Stack tags

`Ruby on Rails 8` `PostgreSQL 16` `pgvector` `Hotwire` `Turbo 8` `Stimulus` `Tailwind CSS v4` `Solid Queue / Cache / Cable` `Postgres RLS` `Docker` `Kamal 2`

### Suggested image gallery (order)

1. `01-home-dark.png`
2. `04-kanban.png`
3. `09-timeline.png`
4. `07-workload.png`
5. `08-calendar.png`
6. `05-issue.png`

---

## 2. Fiverr gig

### Gig title (80 char max)

> I will build a production-ready multi-tenant SaaS on Ruby on Rails 8

### Search tags (5 max)

`ruby-on-rails` `saas-development` `multi-tenant` `postgresql` `hotwire`

### Category

`Programming & Tech > Website Development > Website Builders & CMS` or `Custom Websites`

### Gig description

**Intro**
> I design and ship production-ready multi-tenant SaaS applications on Ruby on Rails 8. I recently built Tracklane, a full project management platform with real-time kanban, AI-powered triage, Gantt view, wiki, and cross-tenant Row-Level Security. Source and screenshots: https://github.com/atifali-pm/tracklane

**What I deliver**
- Clean Rails 8 codebase with Hotwire, Solid Queue, Solid Cable, Postgres, Kamal 2
- Strict multi-tenancy with Postgres Row-Level Security and isolation tests from day one
- Modern UI with Tailwind CSS v4, dark mode, real-time updates via Turbo Streams
- Background jobs, email delivery, webhooks, and deploy scripts included
- Bring-your-own-key AI integration (Claude, Gemini, OpenAI) when you need it

**What I need from you**
- A clear description of the workflow your users will run
- Your preferred hosting target (Fly.io, Render, Hetzner, your own VPS)
- Any branding assets (logo, color) if you have them, otherwise I ship with neutral defaults

### Package tiers

| Tier | Scope | Delivery | Price (placeholder, set your own) |
|---|---|---|---|
| **Basic** | Rails 8 skeleton with auth, a single resource model, Tailwind UI, Postgres, tests | 5 days | `$___` |
| **Standard** | Basic plus multi-tenancy with RLS, role-gated access, 2 real-time features (kanban or live feed), Solid Queue background jobs, email delivery | 10 days | `$___` |
| **Premium** | Standard plus AI integration (triage or RAG chat), a second complex view (Gantt or calendar), webhook system, production deploy to your chosen host with CI | 20 days | `$___` |

### FAQ

**Q. Do you use AI tools to write the code?**
> Yes, I use Claude Code to move faster, and I review, test, and own every line that ships. Full test suite and CI gate.

**Q. Will the code be fully mine?**
> Yes, delivered MIT-licensed or under whatever license you pick.

**Q. Can I self-host?**
> Yes, all my work is Kamal-ready and can deploy to any VPS. Render, Fly.io, Railway, or your own Hetzner / DigitalOcean box.

**Q. Do you do redesigns or only new builds?**
> Both. I have done 4 multi-tenant SaaS projects in production (Ruby, Node.js/TypeScript, Next.js), message me and I will match what you need.

---

## 3. Upwork profile

### Profile title (70 char max)

> Senior Ruby on Rails developer · Multi-tenant SaaS & Hotwire specialist

### Overview (first 150 chars appear in search)

> I design and ship multi-tenant SaaS on Rails 8 with Hotwire, Postgres Row-Level Security, real-time updates, and AI integration. 15 years in web, 5 in multi-tenant SaaS. Recent work includes Tracklane (full PM platform, public repo).

**Full overview**

> I am a senior Ruby on Rails developer focused on multi-tenant SaaS. I build Rails 8 apps that hold up in production: strict tenant isolation via Postgres Row-Level Security, real-time UI with Hotwire and Turbo Streams, background jobs on Solid Queue, and deployment via Kamal 2.
>
> Recent work:
>
> - **Tracklane** (public): a full project management SaaS on Rails 8 with kanban, timeline, wiki, time tracking, and optional Claude-powered triage. 79 integration tests, 200 assertions, Monday-style UI, dark mode. Source: https://github.com/atifali-pm/tracklane
> - **Caseflow** (Laravel): multi-tenant case management platform
> - **StoreBridge** (Node.js / TypeScript): multi-tenant e-commerce middleware
> - **LearnLoop** (Next.js / Prisma): multi-tenant LMS
> - **Axon** (Next.js / Fastify): multi-tenant agent orchestration
>
> What I do well:
>
> - Row-Level Security done right, with a real isolation test suite before one line of business code lands
> - Clean Hotwire-first UIs with zero SPA framework, dark mode, drag-drop, live feeds
> - Bring-your-own-key AI integration that degrades gracefully when no key is set
> - CI, tests, and deploy scripts from day one, not bolted on at the end
>
> I work async across timezones, communicate in crisp writing, and deliver on agreed scope.

### Skills (tags)

`Ruby on Rails` `PostgreSQL` `Hotwire` `Multi-tenant SaaS` `Redis` `Background Jobs` `AI Integration` `Row-Level Security` `Turbo` `Stimulus` `Tailwind CSS` `Kamal` `Docker` `TypeScript`

### Hourly rate

> Placeholder: `$__` per hour. Competitive EU RoR freelance range is $50 to $120.

### Portfolio item: Tracklane

**Title**
> Tracklane · multi-tenant project management SaaS on Rails 8

**One-line summary**
> I built a full PM SaaS from scratch on Rails 8 with kanban, timeline, wiki, time tracking, AI triage, and strict tenant isolation.

**Description**
> Tracklane is a multi-tenant project management platform I built to show what a modern Rails product looks like in 2026. 11 of 12 planned phases shipped with a 79-test isolation suite proving tenant separation at the database level.
>
> Highlights:
>
> - Multi-tenant by design with Postgres Row-Level Security on every tenant-scoped table, enforced through a NOSUPERUSER app role
> - Kanban board with Stimulus drag-and-drop and Turbo Stream live updates
> - Timeline view driven by per-issue start and due dates, calendar, workload view grouping by assignee
> - Markdown wiki per project, time tracking per issue, activity feed with live updates
> - Optional Claude-powered issue triage and pgvector-backed "ask your project" chat, both bring-your-own-key
> - Solid Queue, Solid Cable, Solid Cache, Kamal 2 ready
> - Dark mode with async toggle, Monday-style sidebar and right rail

**Skills used**
> Ruby on Rails 8, PostgreSQL, pgvector, Hotwire, Stimulus, Turbo Streams, Tailwind CSS v4, Solid Queue, Postgres RLS, Kamal 2, Anthropic API, Docker

**Project URL**
> https://github.com/atifali-pm/tracklane

**Cover image**
> `public/screenshots/01-home-dark.png`

**Gallery (order)**
1. `01-home-dark.png`
2. `04-kanban.png`
3. `09-timeline.png`
4. `07-workload.png`
5. `05-issue.png`
6. `10-ask-ai.png`
7. `08-calendar.png`
8. `13-wiki-empty.png`

---

## 4. LinkedIn "featured" post

### Short version (1200 chars)

> I just shipped Tracklane, a multi-tenant project management SaaS I built from scratch on Ruby on Rails 8 to show what a 2026 Rails product looks like.
>
> 11 of 12 planned phases done in 14 sessions:
> - Kanban board with drag-drop and real-time updates via Turbo Streams
> - Timeline, calendar, workload, and Markdown wiki views
> - Time tracking per issue, activity feed, email notifications
> - Claude-powered issue triage and pgvector "ask your project" chat, both bring-your-own-key so the app stays fully usable when AI is off
> - Strict multi-tenancy: every tenant-scoped table has a Postgres Row-Level Security policy plus a 79-test integration suite that proves cross-tenant reads and writes are rejected
>
> Stack: Rails 8, Postgres 16 + pgvector, Hotwire, Solid Queue / Cable / Cache, Tailwind v4, Kamal 2.
>
> Source and screenshots: https://github.com/atifali-pm/tracklane
>
> Open to senior Ruby on Rails roles across EU and remote. DMs open.

### Hashtags (use 3 to 5 max)

`#RubyOnRails #Hotwire #SaaS #PostgreSQL #OpenSource`

### Image

> Attach `public/screenshots/01-home-dark.png` (or a GIF of drag-drop if you want more engagement, `ffmpeg` recording from the kanban page works well).

---

## 5. Social post variants

### Twitter / X (280 chars)

> Shipped Tracklane, a multi-tenant PM SaaS on Rails 8: kanban, timeline, wiki, AI triage, all with Postgres Row-Level Security proven by a 79-test isolation suite. Source + screenshots → https://github.com/atifali-pm/tracklane

### Hacker News "Show HN" title

> Show HN: Tracklane, a Rails 8 project management SaaS with RLS-backed multi-tenancy

### Hacker News body

> Built this to replace the "Redmine with an AI layer" gap: Rails 8, Hotwire, Postgres RLS with a real isolation test suite, kanban with live updates, Gantt timeline, wiki, time tracking. Claude triage and RAG chat are BYOK and gated off by default. 11 of 12 planned phases landed. Open source under MIT.
>
> The thing I am most happy with is the RLS layer. Two roles (owner for DDL, NOSUPERUSER for app), per-request `app.current_organization_id` and `app.current_user_id` GUCs, plus 79 integration tests that try every direction of cross-tenant SELECT / INSERT / UPDATE / DELETE. I would welcome critique on that specifically.

---

## 6. What to swap in

- `$___` placeholders in Fiverr tiers and Upwork hourly rate
- "Live demo URL (add once Render deploy lands)" on the portfolio hero
- Any years-of-experience number I used (tweak to actual count)
- Screenshot paths if you rename files
