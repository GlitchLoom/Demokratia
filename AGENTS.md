# Demokratia Flutter app — agent orchestration

This file receives a request about the Demokratia Flutter app (single iOS + Android codebase) and routes it to the right specialized subagent in `.claude/agents/`. The main Claude session acts as orchestrator: it delegates, it does not implement layer work itself. This file contains no application logic.

## Global architectural constraints

Valid for **all** agents, regardless of who handles the request:

- **Clean Architecture**: `lib/domain` → `lib/data` + `lib/presentation` (never the reverse). Details and checklist: `.claude/skills/clean-architecture-boundaries/SKILL.md`.
- **MVVM-C**: declarative widget ← ViewModel (observable state) ← Coordinator (navigation). Details: `.claude/skills/mvvm-c-pattern/SKILL.md`.
- **Backend via REST API**: no real OpenAPI spec yet for most resources — start from the data model in `docs/BOOTSTRAP.md` §10 and the real facts in `.claude/skills/rest-api-consumption/SKILL.md`.
- **Authentication**: Nostr login (`.claude/skills/nostr-auth/SKILL.md`, epic E1).
- **UI**: the single source of truth is `docs/mockup/index.html` (screens) and `docs/mockup/design-system.html` (Timbro Comunale palette, typography, components). No screen or component departs from the mockup without an explicit reason.
- **Product principles** (`docs/BOOTSTRAP.md` §4): no opaque ranking, equal visibility for citizens and organizations, event subscription as an explicit user commitment, minimal data, no advertising profiling.
- **Responsive and stable UI**: every screen adapts to any size, orientation and text scale, with no overflow and no layout shifts while the user interacts. Details and required tests: `.claude/skills/responsive-layout-stability/SKILL.md`.
- **Accepted technical decisions**: `docs/adr/` (state management, router, HTTP, DB, DI, min OS). Read the relevant ADR before implementing; do not deviate without a new ADR approved by a human. ADRs with status Proposed are not binding.
- **Cross-platform**: the code lives in `lib/` and is shared by iOS and Android; platform-specific code (permissions, push, native deep links) stays isolated behind `domain`/`data` interfaces.

## Routing table

| If the request is about... | Route to | Subagent file |
|---|---|---|
| New entity, new use case, business rule, Repository interfaces | Domain Agent | `.claude/agents/domain-agent.md` |
| API call, DTO, mapper, offline cache, token/auth | Data Agent | `.claude/agents/data-agent.md` |
| Screen state, handling a user action, data↔ViewModel binding | Presentation Agent | `.claude/agents/presentation-agent.md` |
| Widget, theme, color, font, screen layout, accessibility | UI & Design System Agent | `.claude/agents/ui-design-system-agent.md` |
| Navigation, router, deep links, onboarding flow | Coordinator/Navigation Agent | `.claude/agents/coordinator-agent.md` |
| Dependency injection, `main()`, environment/flavor config, push registration | DI & App Composition Agent | `.claude/agents/di-composition-agent.md` |
| Unit tests, widget tests, golden tests, coverage, boundary verification | Testing Agent | `.claude/agents/testing-agent.md` |

An ambiguous or cross-cutting request (e.g. "add screen X") touches several agents in sequence — see below.

## Agent collaboration rules

A high-level request almost always breaks down in this order (skip a step if it is not needed):

1. **Domain Agent** — is there a new entity or use case to define?
2. **Data Agent** — is a new endpoint/Repository needed to support it?
3. **Presentation Agent** — is a new ViewModel or extra state needed?
4. **UI & Design System Agent** — is a new widget or visual screen needed?
5. **Coordinator/Navigation Agent** — is a new navigation point or deep link needed?
6. **Testing Agent** — test coverage for everything produced above.

The **DI & App Composition Agent** steps in only when the app's composition/startup changes (a new dependency to wire), not for every request.

## Working from the plan

Development tasks come from `docs/plan/` (index: `docs/plan/README.md`, one file per epic). The skill `.claude/skills/plan-driven-workflow/SKILL.md` applies to every agent.

1. A request names a task ID (e.g. "Do E3-T2"). Read that task and its dependencies before routing; the task's *Tech* line says which agents are involved.
2. One task per request. If it cannot be a single reviewable change, propose a split and wait.
3. Tasks marked **BE-blocked** are built contract-first against a Fake repository; never invent endpoints beyond the epic's proposed contract.
4. Any work touching key custody or signing needs human security review.
5. Finish with tests and `flutter analyze`, then **stop at the task's Human review point** and report: what was done, what was tested, deviations, open questions. Do not self-merge.

## Agents and skills

Subagents live in `.claude/agents/*.md` and preload their skills through the `skills:` frontmatter field. Skills live in `.claude/skills/<name>/SKILL.md`. Subagents start with an empty context, so every delegation prompt must carry the task ID and any facts the agent needs.
