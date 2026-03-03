# Cursoreception

A Cursor IDE plugin (adapted from [Claudeception](https://github.com/blader/Claudeception)) that enables Cursor's AI agent to extract non-obvious knowledge from work sessions into reusable Skills or Rules that auto-load when similar problems arise.

## What's Included

| Component | Description |
|---|---|
| **Skill** (`skills/cursoreception/`) | Core extraction engine — knows how to identify, format, and save knowledge |
| **Rule** (`rules/cursoreception-evaluate.mdc`) | Always-on evaluator that reminds the agent to assess every task for extractable knowledge |
| **Hook** (`hooks/hooks.json` + `scripts/`) | `stop` hook — auto-prompts the agent to evaluate for extractable knowledge after each completed task |

## How It Works

1. **Install the plugin** — from Cursor Marketplace or manually
2. **`alwaysApply` rule** loads — reminds the agent to evaluate each task after completion
3. **`stop` hook** fires — when the agent completes a task, it automatically sends a follow-up message to trigger knowledge evaluation
4. **Knowledge extraction** — if valuable knowledge is identified, it gets saved as a Skill or Rule

No manual bootstrap needed. The plugin handles everything automatically.

## Installation

### From Cursor Marketplace

Search for **cursoreception** in the Cursor Marketplace panel and click Install.

### Manual Install (without publishing)

Clone the repo, then run the install script:

```bash
git clone <repo-url> cursoreception && cd cursoreception
```

**User-level** (skill + hook available globally, rule needs per-project copy):

```bash
./install.sh --user
```

**Project-level** (all components installed into `<project>/.cursor/`):

```bash
./install.sh --project ~/my-project
```

**Uninstall:**

```bash
./install.sh --user --uninstall
./install.sh --project ~/my-project --uninstall
```

The script copies each component to the correct Cursor location:

| Component | Project (`--project`) | User (`--user`) |
|---|---|---|
| Rule | `<project>/.cursor/rules/` | N/A (rules are project-only) |
| Skill | `<project>/.cursor/skills/cursoreception/` | `~/.cursor/skills/cursoreception/` |
| Hook + Script | `<project>/.cursor/hooks.json` + `.cursor/scripts/` | `~/.cursor/hooks.json` + `~/.cursor/scripts/` |

Restart Cursor after installation.

## Usage

### Automatic Mode (default)

The plugin works silently in the background:

- The **rule** (`alwaysApply: true`) ensures the agent evaluates every task
- The **`stop` hook** prompts the agent to review for extractable knowledge after each completed task

### Explicit Mode

```
/cursoreception
```

Or:

```
Save what we just learned as a skill
Save this pattern as a rule
What did we learn this session?
```

### What Gets Created

**Skills** (`.cursor/skills/<name>/SKILL.md`) for complex knowledge:
- Multi-step debugging guides
- Error message → root cause mappings
- Tool/API integration knowledge

**Rules** (`.cursor/rules/<name>.mdc`) for concise patterns:
- Project coding conventions
- File-type-specific patterns (via `globs`)
- Short, universal directives

## Plugin Structure

```
cursoreception/
├── .cursor-plugin/
│   └── plugin.json            # Plugin manifest
├── rules/
│   └── cursoreception-evaluate.mdc  # Always-on evaluation rule
├── skills/
│   └── cursoreception/
│       └── SKILL.md           # Core extraction skill
├── hooks/
│   └── hooks.json             # Hook definitions
├── scripts/
│   └── stop-evaluate.sh       # stop: trigger knowledge evaluation
├── assets/
│   └── logo.svg               # Plugin logo
├── LICENSE
└── README.md
```

## Differences from v1 (Skill-only)

| Aspect | v1 (Skill) | v2 (Plugin) |
|---|---|---|
| Installation | `git clone` to skills dir | Marketplace or plugins dir |
| Bootstrap | Runtime self-install of rule | Rule packaged with plugin |
| Activation | Semantic matching only | Hook + Rule + Semantic matching |
| Post-task trigger | Relied on rule reminder only | `stop` hook auto-prompts |
| Distribution | Manual | Cursor Marketplace |

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
