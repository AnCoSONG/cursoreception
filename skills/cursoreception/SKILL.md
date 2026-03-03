---
name: cursoreception
description: "Continuous learning system for Cursor IDE. Extracts reusable knowledge from work sessions into new Skills or Rules. Use when: (1) /cursoreception command to review session learnings, (2) 'save this as a skill' or 'extract a skill from this', (3) 'what did we learn?', (4) After debugging, error resolution, workarounds, or trial-and-error discovery, (5) After fixing a bug where the root cause was non-obvious, (6) After finding a configuration or setup that differs from documentation. Helps preserve non-trivial knowledge so it auto-loads in future sessions."
---

# Cursoreception

You are Cursoreception: a continuous learning system for Cursor IDE that extracts reusable
knowledge from work sessions and codifies it into new Cursor Skills or Rules.

## Cursor's Two Knowledge Systems

Cursor provides two complementary mechanisms. Choose based on the nature of the knowledge:

### Skills (`SKILL.md`)
- Rich, detailed knowledge packages (problem + trigger + solution + verification)
- Location: `.cursor/skills/[name]/SKILL.md` (project) or `~/.cursor/skills/[name]/SKILL.md` (user)
- Loaded via semantic matching on `description`
- Best for: complex debugging, multi-step solutions, deep domain knowledge

### Rules (`.mdc`)
- Concise, actionable directives (under 50 lines)
- Location: `.cursor/rules/[name].mdc`
- Loaded via `alwaysApply: true`, `globs` file matching, or agent-picked via `description`
- Best for: coding conventions, project patterns, file-type-specific knowledge

### Decision Matrix

| Knowledge type | Format | Why |
|---|---|---|
| Complex debugging with multiple steps | Skill | Needs context, solution, verification |
| Error message → root cause mapping | Skill | Needs trigger conditions and detailed fix |
| "Always use X pattern in this project" | Rule (`alwaysApply`) | Short, universal |
| "When editing *.prisma files, do X" | Rule (`globs`) | File-type-specific |
| Tool/API usage that docs don't cover | Skill | Needs examples and edge cases |
| Project architecture decisions | Rule (`alwaysApply`) | Conventions that apply everywhere |

## When to Extract

Extract knowledge when you encounter:

1. **Non-obvious Solutions**: Debugging techniques or workarounds that required significant
   investigation and wouldn't be immediately apparent.
2. **Project-Specific Patterns**: Conventions or architectural decisions specific to this
   codebase that aren't documented elsewhere.
3. **Tool Integration Knowledge**: How to use a tool, library, or API in ways documentation
   doesn't cover well.
4. **Error Resolution**: Specific error messages and their actual root causes/fixes,
   especially when the error message is misleading.
5. **Workflow Optimizations**: Multi-step processes that can be streamlined.

## Quality Criteria

Before extracting, verify ALL of these:

- **Reusable**: Will this help with future tasks? (Not just this one instance)
- **Non-trivial**: Requires discovery, not just documentation lookup?
- **Specific**: Can you describe exact trigger conditions and solution?
- **Verified**: Has this solution actually worked?

## Extraction Process

### Step 1: Check for Existing Knowledge

Search both skills and rules before creating anything new.

```sh
SKILL_DIRS=(
  ".cursor/skills"
  "$HOME/.cursor/skills"
)

rg --files -g 'SKILL.md' "${SKILL_DIRS[@]}" 2>/dev/null
rg -i "keyword1|keyword2" "${SKILL_DIRS[@]}" 2>/dev/null
rg --files -g '*.mdc' .cursor/rules/ 2>/dev/null
rg -i "keyword1|keyword2" .cursor/rules/ 2>/dev/null
```

| Found | Action |
|---|---|
| Nothing related | Create new |
| Same trigger and same fix | Update existing (bump version) |
| Same trigger, different root cause | Create new, add `See also:` links |
| Partial overlap | Update existing with new variant |
| Stale or wrong | Deprecate, create replacement |

### Step 2: Identify the Knowledge

- What was the problem or task?
- What was non-obvious about the solution?
- What would someone need to know to solve this faster next time?
- What are the exact trigger conditions (error messages, symptoms, contexts)?

### Step 3: Research Best Practices (When Appropriate)

Search the web when the topic involves specific technologies/frameworks, you're uncertain
about current best practices, or the solution might have changed recently. Skip for
project-specific internal patterns or stable, well-understood concepts.

### Step 4: Choose Format and Create

**If creating a Skill** — save to `.cursor/skills/[name]/SKILL.md`:

```markdown
---
name: descriptive-kebab-case-name
description: |
  Precise description with: (1) exact use cases, (2) trigger conditions like
  specific error messages or symptoms, (3) what problem this solves.
---

# Skill Name

## Problem
[Clear description of the problem]

## Context / Trigger Conditions
[When should this activate? Include exact error messages, symptoms, scenarios]

## Solution
[Step-by-step solution]

## Verification
[How to verify it worked]

## Example
[Concrete example]

## Notes
[Caveats, edge cases, related considerations]
```

**If creating a Rule** — save to `.cursor/rules/[name].mdc`:

```markdown
---
description: Precise description for agent matching. Include trigger terms.
globs: **/*.ext
alwaysApply: false
---

# Rule Title

[Concise, actionable content. Under 50 lines.]
```

### Step 5: Write Effective Descriptions

The `description` field is critical for discovery. Include:

- **Specific symptoms**: Exact error messages, unexpected behaviors
- **Context markers**: Framework names, file types, tool names
- **Action phrases**: "Use when...", "Helps with...", "Solves..."

```yaml
# Good
description: |
  Fix for "ENOENT: no such file or directory" errors when running npm scripts
  in monorepos. Use when: (1) npm run fails with ENOENT in a workspace,
  (2) paths work in root but not in packages.

# Bad
description: Helps with npm problems
```

### Step 6: Save Location

| Scope | Skills | Rules |
|---|---|---|
| Project-level | `.cursor/skills/[name]/SKILL.md` | `.cursor/rules/[name].mdc` |
| User-level | `~/.cursor/skills/[name]/SKILL.md` | N/A (rules are project-only) |

## Retrospective Mode

When `/cursoreception` is invoked:

1. **Review the Session**: Analyze the conversation for extractable knowledge
2. **Identify Candidates**: List potential extractions with brief justifications
3. **Choose Format**: Skill or Rule for each candidate
4. **Extract**: Create the files (typically 1-3 per session)
5. **Summarize**: Report what was created and why

## Self-Reflection Prompts

- "What did I just learn that wasn't obvious before starting?"
- "If I faced this exact problem again, what would I wish I knew?"
- "What error message or symptom led me here, and what was the actual cause?"
- "Is this pattern specific to this project, or would it help in similar projects?"
- "What would I tell a colleague who hits this same issue?"

## Integration with Workflow

### Explicit Invocation

- User runs `/cursoreception`
- User says "save this as a skill" or "save this as a rule"
- User asks "what did we learn?"

### Self-Check After Each Task

After completing any significant task, ask yourself:
- "Did I just spend meaningful time investigating something?"
- "Would future-me benefit from having this documented?"
- "Was the solution non-obvious from documentation alone?"

If yes to any, invoke this skill immediately.

## Quality Gates

- [ ] Description contains specific trigger conditions
- [ ] Solution has been verified to work
- [ ] Content is specific enough to be actionable
- [ ] Content is general enough to be reusable
- [ ] No sensitive information (credentials, internal URLs)
- [ ] Doesn't duplicate existing skills/rules
- [ ] Correct format chosen (Skill vs Rule)
- [ ] If Rule: under 50 lines, with correct `globs`/`alwaysApply`
- [ ] If Skill: includes Problem, Trigger, Solution, Verification sections

## Anti-Patterns

- **Over-extraction**: Not every task deserves preservation. Mundane solutions don't qualify.
- **Vague descriptions**: "Helps with React problems" won't surface when needed.
- **Unverified solutions**: Only extract what actually worked.
- **Wrong format**: Don't stuff a 200-line guide into a Rule. Don't create a Skill for "always use semicolons."
- **Documentation duplication**: Link to official docs; add what's missing from them.
