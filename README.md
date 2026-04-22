# Tracklane

Modern, AI-first project management for teams that want their own.

## What it does

Tracklane is a multi-tenant project management platform. Teams collaborate across projects, track issues, run kanban boards, and keep a wiki per project. Instead of bolting AI on as a feature, Tracklane uses Claude in the core workflow: it triages new issues, summarizes what is at risk each morning, and lets the team ask questions across everything the project has ever produced.

## Who it is for

- Teams that want a Redmine-level feature set without a 2006-era experience
- Organizations that need privacy and data sovereignty, so self-hosting is the default
- Operators who prefer to own their stack and run it on their own infrastructure rather than trust a closed SaaS

## Features

### Core project management

- Organizations with multiple projects per organization
- Role-gated access: admin, manager, member, viewer
- Issues with status, priority, labels, assignee, and due date
- Comments, mentions, and an activity feed per project
- Kanban board with drag-and-drop and live updates across every connected user
- Email notifications for assignments, mentions, and status changes
- Full text search across issues, comments, and wiki

### AI that earns its place

- **Issue triage.** New issues get an AI-suggested priority, labels, and assignee based on the description and what the project has resolved before. The user confirms or overrides.
- **Ask your project.** A chat interface that answers questions across every issue, comment, and wiki page in the project. Answers cite the source thread.
- **Daily team digest.** Each morning, every organization gets an email summarizing what shipped yesterday, what is blocked, and what is at risk of missing its due date.
- **Meeting to tickets.** Paste a meeting transcript, and Tracklane extracts action items as draft issues with suggested owners. The user reviews before creating them.
- **Auto-generated release notes.** On a release tag, closed issues turn into human-readable release notes.

### Team infrastructure

- Wiki per project with Markdown editing and history
- Time tracking per issue
- Gantt view for scheduling
- Outbound webhooks with signed payloads for integrating with anything else the team uses
- Hosted or self-hosted: run Tracklane on your own server with a single deploy command

## Roadmap

### Phase 1 - Core foundations

- Organizations, memberships, and roles
- Projects and invitations
- Issues, comments, and mentions
- Kanban board with live updates
- Activity feed and email notifications

### Phase 2 - AI layer

- Issue triage on create
- Ask your project chat
- Daily team digest
- Meeting to tickets extractor

### Phase 3 - Polish

- Gantt view, time tracking, wiki
- Outbound webhooks
- Production deploy target

## Screenshots

Coming once the MVP is live.

## Project links

- Author: [Atif Ali](https://github.com/atifali-pm)
- Portfolio: [github.com/atifali-pm](https://github.com/atifali-pm)
