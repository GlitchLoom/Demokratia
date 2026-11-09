---
name: plan-driven-workflow
description: "Use at the start of every request that names a plan task (e.g. E3-T2): how agents work from docs/plan/ with one atomic task per request, contract-first for backend gaps, tests included, and a mandatory human review stop."
---

# plan-driven-workflow

How agents work from docs/plan/: one atomic task per request, contract-first for backend gaps, tests included, and a mandatory human review stop.

## Checklist

- Start from a task ID (e.g. E3-T2): read that task in docs/plan/ and its 'Depends on'; if a dependency is not done, stop and say so instead of working around it
- Do exactly the task: no drive-by refactors or extra features; if the task is too big for one reviewable change, propose a split and wait
- Check the backend readiness line of the epic: for BE-blocked tasks build against a Fake repository and never invent endpoints beyond the 'proposed contract' in the epic file
- A fake and its real counterpart must pass the same repository test suite
- Write the tests listed in the task's Test section together with the code; run flutter analyze and flutter test before reporting
- Stop at the task's Human review point: report what was done, what was tested, deviations from the mockup or plan, and open questions; do not merge or self-approve
- Human gates (architecture choices, crypto/key custody, contract deviations, privacy-relevant data, visual deviations) must never be decided by the agent: propose options and wait
- Never touch credentials, signing keys, Firebase/APNs secrets or store accounts; ask the human to provide them as CI secrets
- Record decisions as ADRs in docs/adr/ (the folder is created by the first ADR, task E0-T1; docs/privacy-data-flows.md is an output of E9, not an existing file) and keep the plan files in sync (status of the task, new tasks appended, never renumbered)

## Source of truth

- `docs/plan/README.md`

## Used by

domain-agent, data-agent, presentation-agent, ui-design-system-agent, coordinator-agent, di-composition-agent, testing-agent
