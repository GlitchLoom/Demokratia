@AGENTS.md

## Claude Code notes

- Delegate layer work to the matching subagent in `.claude/agents/`; pass the task ID (e.g. `E3-T2`) and the paths it needs in the prompt.
- One task per request. Stop at the task's Human review point; never self-merge or commit unless asked.
- Layer boundary rules are in `.claude/rules/`. Hard limits (secrets, keys) are enforced by `.claude/settings.json`, not by this file.
- Keep this file short; procedures belong in skills.
