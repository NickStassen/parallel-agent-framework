# PAF Quick Reference Card

One-page reference for using the Parallel Agent Framework.

---

## 🚀 Installation

```bash
cd /home/nick/Workspace/parallel-agent-framework
./install.sh
```

---

## 📋 Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `paf-init` | Initialize PAF in current dir | `cd ~/project && paf-init` |
| `paf-spawn` | Spawn agent wave | `paf-spawn "Wave 1" A1 A2 A3` |
| `paf-status` | Check completion | `paf-status` |
| `paf-validate` | Validate findings | `paf-validate` |
| `paf-clean` | Clean artifacts | `paf-clean` |

---

## ⚡ Typical Workflow

```bash
# 1. Initialize
cd ~/my-project
paf-init

# 2. Define agents
vim .paf/AGENT_CHARTER.md
vim .paf/DEPENDENCY_DAG.md

# 3. Create prompts
vim .paf/prompts/AGENT_A1_PROMPT.md
vim .paf/prompts/AGENT_A2_PROMPT.md
vim .paf/prompts/AGENT_A3_PROMPT.md

# 4. Execute Wave 1
paf-spawn "Wave 1" A1 A2
paf-status

# 5. Execute Wave 2
paf-spawn "Wave 2" A3
paf-status

# 6. Validate
paf-validate

# 7. Review findings
cat .paf/findings/A1_FINDINGS.md
cat .paf/findings/A2_FINDINGS.md
cat .paf/findings/A3_FINDINGS.md

# 8. Synthesize final plan (manually or with another agent)
```

---

## 📁 Directory Structure

After `paf-init`:
```
.paf/
├── README.md               ← Quick start guide
├── AGENT_CHARTER.md        ← Edit: Define agents
├── DEPENDENCY_DAG.md       ← Edit: Map dependencies
├── prompts/                ← Create: Agent instructions
│   ├── AGENT_A1_PROMPT.md
│   ├── AGENT_A2_PROMPT.md
│   └── AGENT_A3_PROMPT.md
├── findings/               ← Generated: Agent outputs
│   ├── A1_FINDINGS.md
│   ├── A2_FINDINGS.md
│   └── A3_FINDINGS.md
└── status/                 ← Generated: Completion signals
    ├── A1_STATUS.md
    ├── A2_STATUS.md
    └── A3_STATUS.md
```

---

## 📝 Agent Prompt Template

Minimal template for `.paf/prompts/AGENT_AX_PROMPT.md`:

```markdown
# Agent AX: [Role Name]

## Your Mission
[One sentence task]

## Context Files (READ ONLY THESE)
- `path/file1` - [why needed]
- `path/file2` - [why needed]

## Your Task
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Output Format (STRICTLY FOLLOW)
[Use template from templates/AGENT_PROMPT_TEMPLATE.md]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Time Budget
15 minutes maximum

---
BEGIN WORK NOW.
```

---

## 🎯 Wave Execution Patterns

### Pattern 1: All Parallel (No Dependencies)
```bash
paf-spawn "Analysis" A1 A2 A3 A4
```

### Pattern 2: Sequential Waves
```bash
paf-spawn "Wave 1" A1 A2    # Parallel
paf-status && \
paf-spawn "Wave 2" A3 A4    # Depends on Wave 1
paf-status && \
paf-spawn "Wave 3" A5       # Depends on Wave 2
```

### Pattern 3: Mixed Dependencies
```bash
# Independent agents
paf-spawn "Wave 1" A1 A2 A3

# A4 depends on A1 and A2, A5 depends on A3
paf-status && \
paf-spawn "Wave 2" A4 A5

# A6 depends on all
paf-status && \
paf-spawn "Wave 3" A6
```

---

## ✅ Required Sections in Findings

Every `findings/AX_FINDINGS.md` must include:

```markdown
## Executive Summary
[2-3 sentences]

## Key Findings
1. **[Title]**: [Details]
2. **[Title]**: [Details]

## Recommendations
1. [Action with rationale]

## Confidence Level
**HIGH** - [Justification]
```

Use `paf-validate` to check format compliance.

---

## 🔧 Debugging

### Check What Failed
```bash
paf-status
cat .paf/status/A1_STATUS.md
```

### Review Agent Output
```bash
cat .paf/findings/A1_FINDINGS.md
```

### Kill Hung Agents
```bash
ps aux | grep claude
kill -9 <PID>
paf-clean
```

### Validate Format
```bash
paf-validate
# Shows which agents have invalid output
```

---

## 💡 Tips

1. **Start small:** 3 agents, 1 wave for first try
2. **Test prompts:** Run one agent manually first
3. **Validate early:** Use `paf-validate` after each wave
4. **Clear outputs:** Use `paf-clean` between iterations
5. **Read examples:** See `EXAMPLES.md` for patterns

---

## 📚 Full Documentation

- **Framework:** `FRAMEWORK.md` - Complete specification
- **Installation:** `INSTALL.md` - Detailed setup guide
- **Examples:** `EXAMPLES.md` - Real-world use cases
- **Best Practices:** `docs/BEST_PRACTICES.md` - Tips & anti-patterns
- **Usage Reference:** `~/.config/paf/USAGE.txt` - Command reference

---

## 🆘 Common Issues

| Problem | Solution |
|---------|----------|
| `paf-init: command not found` | Add `~/.local/bin` to PATH |
| Agent times out | Increase timeout: `AGENT_TIMEOUT=900 paf-spawn ...` |
| Validation fails | Check findings has required sections |
| All agents fail | Verify prompt files exist in `.paf/prompts/` |

---

**Version:** 2.0
**Location:** `/home/nick/Workspace/parallel-agent-framework`
**Config:** `~/.config/paf/`
