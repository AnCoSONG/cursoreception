# Cursoreception

A Cursor IDE adaptation of [Claudeception](https://github.com/blader/Claudeception). Enables Cursor's AI agent to extract non-obvious knowledge from work sessions into reusable Skills or Rules that auto-load when similar problems arise.

## How It Works

1. **Install the skill** — clone to `~/.cursor/skills/` or `.cursor/skills/`
2. **Semantic matching** — Cursor loads the skill when conversation context matches its description (debugging, error resolution, workarounds, etc.)
3. **Self-bootstrap** — on first activation, the skill automatically creates an `alwaysApply` rule at `.cursor/rules/cursoreception-evaluate.mdc`, ensuring the agent evaluates every future task for extractable knowledge
4. **Knowledge extraction** — when valuable knowledge is identified, it gets saved as a new Skill or Rule

After the one-time bootstrap, the system is fully autonomous. No manual file copying needed.

## Installation

### User-level (recommended)

Available across all your projects.

```bash
git clone <repo-url> ~/.cursor/skills/cursoreception
```

### Project-level

Available only in this project.

```bash
git clone <repo-url> .cursor/skills/cursoreception
```

That's it. The skill will self-install its `alwaysApply` evaluation rule on first activation.

## Usage

### Automatic Mode

The skill activates via semantic matching when the agent:
- Completes debugging that required non-obvious investigation
- Finds a workaround through trial-and-error
- Resolves an error where the root cause wasn't immediately apparent
- Discovers project-specific patterns through investigation

After bootstrap, the always-evaluate rule reminds the agent to check every task.

### Explicit Mode

```
/cursoreception
```

Or:

```
Save what we just learned as a skill
Save this pattern as a rule
```

### What Gets Created

**Skills** (`.cursor/skills/[name]/SKILL.md`) for complex knowledge:
- Multi-step debugging guides
- Error message → root cause mappings
- Tool/API integration knowledge

**Rules** (`.cursor/rules/[name].mdc`) for concise patterns:
- Project coding conventions
- File-type-specific patterns (via `globs`)
- Short, universal directives

## Differences from Claudeception

| Aspect | Claudeception (Claude Code) | Cursoreception (Cursor) |
|---|---|---|
| Knowledge format | Skills only | Skills + Rules (`.mdc`) |
| Activation | Shell hook + `UserPromptSubmit` | Semantic matching + self-installed `alwaysApply` rule |
| File-specific matching | Semantic only | Semantic + `globs` pattern |
| Skill path | `.claude/skills/` | `.cursor/skills/` |
| Manual setup | Copy hook script + edit settings.json | None (self-bootstrap) |

## Quality Gates

Not everything gets extracted. Knowledge must be:
- **Reusable** — helps with future tasks, not just this one
- **Non-trivial** — requires discovery, not just reading docs
- **Specific** — has clear trigger conditions
- **Verified** — actually tested and confirmed working

## Research

Based on the same academic foundations as Claudeception:
- [Voyager](https://arxiv.org/abs/2305.16291) — skill library architecture
- [CASCADE](https://arxiv.org/abs/2512.23880) — meta-skills for skill acquisition
- [SEAgent](https://arxiv.org/abs/2508.04700) — learning from trial-and-error
- [Reflexion](https://arxiv.org/abs/2303.11366) — self-reflection for improvement

## License

MIT
