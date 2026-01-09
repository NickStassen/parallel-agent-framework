# Installation Guide

Quick guide to installing and using the Parallel Agent Framework.

---

## 🚀 Installation

### Quick Install (Recommended)

```bash
cd /home/nick/Workspace/parallel-agent-framework
./install.sh
```

This installs PAF commands to `~/.local/bin` (user-only, no sudo required).

### Global Install (System-Wide)

```bash
sudo ./install.sh --global
```

This installs PAF commands to `/usr/local/bin` (available to all users).

---

## 📋 Installed Commands

After installation, these commands are available system-wide:

| Command | Description |
|---------|-------------|
| `paf-init` | Initialize PAF in current directory |
| `paf-spawn` | Spawn a wave of agents |
| `paf-status` | Check agent completion status |
| `paf-validate` | Validate findings format |
| `paf-clean` | Clean execution artifacts |

---

## 🎯 Quick Start

### 1. Initialize PAF in Your Project

```bash
cd ~/my-project
paf-init
```

This creates:
```
.paf/
├── README.md
├── AGENT_CHARTER.md (template)
├── DEPENDENCY_DAG.md (template)
├── prompts/
├── findings/
└── status/
```

### 2. Define Your Agents

Edit `.paf/AGENT_CHARTER.md`:
```markdown
## Agent Roster

### Wave 1
| Agent ID | Role | Task | Timeout |
|----------|------|------|---------|
| A1 | Analyzer | Analyze database schema | 15min |
| A2 | Reviewer | Review API endpoints | 15min |
```

### 3. Create Agent Prompts

Create `.paf/prompts/AGENT_A1_PROMPT.md`:
```markdown
# Agent A1: Database Analyzer

## Your Mission
Analyze the database schema and identify all tables, relationships, and indexes.

## Context Files
- `src/models/*.py`
- `migrations/`

## Task
1. List all database tables
2. Map relationships (foreign keys)
3. Document indexes

[... rest of prompt template ...]
```

### 4. Spawn Agents

```bash
# Spawn Wave 1 agents in parallel
paf-spawn "Wave 1" A1 A2

# Check status
paf-status

# Validate outputs
paf-validate
```

---

## 📖 Complete Workflow Example

```bash
# 1. Navigate to your project
cd ~/my-awesome-project

# 2. Initialize PAF
paf-init

# 3. Edit charter and prompts
vim .paf/AGENT_CHARTER.md
vim .paf/DEPENDENCY_DAG.md
vim .paf/prompts/AGENT_A1_PROMPT.md
vim .paf/prompts/AGENT_A2_PROMPT.md

# 4. Execute Wave 1
paf-spawn "Wave 1" A1 A2
paf-status  # Check completion

# 5. Execute Wave 2 (depends on Wave 1)
paf-spawn "Wave 2" A3
paf-status

# 6. Validate all findings
paf-validate

# 7. Read findings and synthesize
cat .paf/findings/A1_FINDINGS.md
cat .paf/findings/A2_FINDINGS.md
cat .paf/findings/A3_FINDINGS.md

# 8. Create final plan (manual synthesis or use another agent)

# 9. Clean up for next run (optional)
paf-clean
```

---

## 🛠️ Advanced Usage

### Custom PAF Directory

```bash
# Use different directory name
PAF_DIR=.agents paf-init
PAF_DIR=.agents paf-spawn "Wave 1" A1 A2
```

### Agent Timeouts

```bash
# Set custom timeout (default: 600s)
AGENT_TIMEOUT=900 paf-spawn "Wave 1" A1 A2
```

### Parallel Wave Script

Create `.paf/run_all_waves.sh`:
```bash
#!/bin/bash
set -e

echo "=== Executing All Waves ==="

# Wave 1
paf-spawn "Wave 1" A1 A2 A3
paf-status

# Validate Wave 1 completed
if paf-validate; then
    echo "Wave 1 validated ✓"
else
    echo "Wave 1 validation failed!"
    exit 1
fi

# Wave 2
paf-spawn "Wave 2" A4 A5
paf-status
paf-validate

echo "=== All Waves Complete ==="
```

---

## 🔧 Troubleshooting

### Command Not Found: paf-init

**Problem:** `~/.local/bin` not in PATH

**Solution:** Add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Agent Fails Immediately

**Check:**
1. Prompt file exists: `ls .paf/prompts/AGENT_A1_PROMPT.md`
2. Prompt is valid markdown
3. Agent timeout is sufficient

### Findings Not Validating

**Check format includes required sections:**
- `## Executive Summary`
- `## Key Findings`
- `## Recommendations`
- `## Confidence Level`

### Agents Hang

**Kill hung agents:**
```bash
ps aux | grep claude
kill -9 <PID>
paf-clean  # Clean partial outputs
```

---

## 📚 Additional Documentation

- **Framework Spec:** `/path/to/parallel-agent-framework/FRAMEWORK.md`
- **Examples:** `/path/to/parallel-agent-framework/EXAMPLES.md`
- **Best Practices:** `/path/to/parallel-agent-framework/docs/BEST_PRACTICES.md`
- **Quick Reference:** `~/.config/paf/USAGE.txt`

---

## 🔄 Updating PAF

```bash
cd /path/to/parallel-agent-framework
git pull origin main
./install.sh  # Reinstall commands
```

---

## 🗑️ Uninstallation

```bash
# Remove commands
rm ~/.local/bin/paf-*

# Remove config
rm -rf ~/.config/paf

# Remove from specific project
rm -rf .paf/
```

---

## 💡 Tips

1. **Start small:** Try 3 agents on a simple task first
2. **Use templates:** Copy from `EXAMPLES.md` as starting points
3. **Validate early:** Run `paf-validate` after each wave
4. **Check status:** Use `paf-status` to monitor progress
5. **Clean between runs:** `paf-clean` prevents stale outputs

---

## 🆘 Getting Help

- **Quick reference:** `cat ~/.config/paf/USAGE.txt`
- **Examples:** Browse `EXAMPLES.md` for real-world patterns
- **GitHub Issues:** Report bugs or request features
- **Documentation:** Read `FRAMEWORK.md` for complete specification
