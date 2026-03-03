# Cursoreception

A Cursor IDE plugin (adapted from [Claudeception](https://github.com/blader/Claudeception)) that enables Cursor's AI agent to extract non-obvious knowledge from work sessions into reusable Skills and Rules that auto-load when similar problems arise. Also updates AGENTS.md with user preferences and workspace facts as a lightweight supplement.

## What's Included

| Component | Description |
|---|---|
| **Skill** (`skills/cursoreception/`) | Core extraction engine — identifies, formats, and saves knowledge as Skills or Rules |
| **Rule** (`rules/cursoreception-evaluate.mdc`) | Always-on evaluator that reminds the agent to assess every task for extractable knowledge |
| **Hook** (`scripts/stop-evaluate.sh`) | `stop` hook — auto-prompts knowledge evaluation after each completed task |

## How It Works

1. **Install the plugin** — from Cursor Marketplace or manually
2. **`alwaysApply` rule** loads — reminds the agent to evaluate each task for extractable Skills/Rules
3. **`stop` hook** fires — after task completion, sends a follow-up message to trigger knowledge evaluation
4. **Knowledge saved** — as Skills (complex) or Rules (concise), plus AGENTS.md for lightweight preferences

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

Restart Cursor after installation.

## Usage

### Automatic Mode (default)

The plugin works silently in the background:

- The **rule** (`alwaysApply: true`) ensures the agent evaluates every task for extractable Skills/Rules
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

## Plugin Structure

```
cursoreception/
├── .cursor-plugin/
│   └── plugin.json                  # Plugin manifest
├── rules/
│   └── cursoreception-evaluate.mdc  # Always-on evaluation rule
├── skills/
│   └── cursoreception/
│       └── SKILL.md                 # Core extraction skill
├── hooks/
│   └── hooks.json                   # Hook definitions
├── scripts/
│   └── stop-evaluate.sh             # stop: trigger knowledge evaluation
├── assets/
│   └── logo.svg                     # Plugin logo
├── install.sh                       # Manual install script
├── LICENSE
└── README.md
```

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
