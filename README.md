# Cursoreception

A Cursor IDE plugin (adapted from [Claudeception](https://github.com/blader/Claudeception)) that enables Cursor's AI agent to **extract and iteratively improve** non-obvious knowledge from work sessions. Knowledge is saved as reusable Skills and Rules that auto-load when similar problems arise, and continuously refined as new insights emerge — with your explicit approval.

## What's Included

| Component | Description |
|---|---|
| **Skill** (`skills/cursoreception/`) | Core engine — extracts new knowledge and proposes updates to existing Skills/Rules |
| **Rule** (`rules/cursoreception-evaluate.mdc`) | Always-on evaluator that reminds the agent to assess every task for new or improvable knowledge |
| **Hook** (`scripts/stop-evaluate.sh`) | `stop` hook — auto-prompts knowledge evaluation after each completed task |

## How It Works

1. **Install the plugin** — from Cursor Marketplace or manually
2. **`alwaysApply` rule** loads — reminds the agent to evaluate each task for extractable or improvable knowledge
3. **`stop` hook** fires — after task completion, sends a follow-up message to trigger evaluation
4. **Knowledge created or updated**:
   - **New knowledge** → saved directly as Skill or Rule
   - **Existing knowledge needs improvement** → update proposal shown via AskQuestion → applied only after your approval

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

**Update an existing installation:**

```bash
./install.sh --user --update
./install.sh --project ~/my-project --update
```

The update command will:
- Compare the installed version with the source version
- Back up existing files before overwriting
- Only update files that have actually changed
- Skip if already up to date

**Uninstall:**

```bash
./install.sh --user --uninstall
./install.sh --project ~/my-project --uninstall
```

Restart Cursor after installation or update.

## Usage

### Automatic Mode (default)

The plugin works silently in the background:

- The **rule** (`alwaysApply: true`) ensures the agent evaluates every task for extractable or improvable knowledge
- The **`stop` hook** prompts the agent to review after each completed task
- When updating an existing skill/rule, the agent asks for your approval first

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
│       └── SKILL.md                 # Core extraction & update skill
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

Not everything gets extracted or updated. Knowledge must be:
- **Reusable** — helps with future tasks, not just this one
- **Non-trivial** — requires discovery, not just reading docs
- **Specific** — has clear trigger conditions
- **Verified** — actually tested and confirmed working

Updates to existing knowledge additionally require:
- **User approval** — proposed via AskQuestion before any change
- **Non-destructive** — preserves existing valid content, adds or refines

## Research

Based on the same academic foundations as Claudeception:
- [Voyager](https://arxiv.org/abs/2305.16291) — skill library architecture
- [CASCADE](https://arxiv.org/abs/2512.23880) — meta-skills for skill acquisition
- [SEAgent](https://arxiv.org/abs/2508.04700) — learning from trial-and-error
- [Reflexion](https://arxiv.org/abs/2303.11366) — self-reflection for improvement

## License

MIT
