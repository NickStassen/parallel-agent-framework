# PAF Auto-Planner: Mode Comparison

**Quick reference for choosing the right mode**

---

## 🎯 Mode Overview

| Mode | Command | Use Case | Output |
|------|---------|----------|--------|
| **Automated** | `paf-plan PLAN.md` | Silent background execution | Saved to file |
| **Live** | `paf-plan PLAN.md --live` | Monitor progress in real-time | Streamed to terminal |
| **Interactive** | `paf-plan PLAN.md --interactive` | Control permissions manually | Streamed to terminal |
| **Dry Run** | `paf-plan PLAN.md --dry-run` | Preview prompt only | Creates prompt file |

---

## 📊 Detailed Comparison

### Automated Mode (Default)

```bash
paf-plan PLAN.md
```

**Characteristics:**
- ✅ Silent execution (no terminal output during run)
- ✅ Uses `--dangerously-skip-permissions` (won't hang)
- ✅ Output saved to `.paf/PLANNER_OUTPUT.md`
- ✅ Best for production/scripted use
- ⏱️ 30-minute timeout (configurable)

**What you see:**
```
📂 Ensuring .paf directory structure...
📝 Creating planner agent prompt...
   Saved to: .paf/PLANNER_AGENT_PROMPT.md

🚀 Starting PAF Auto-Planner Agent
🤖 Spawning planner agent...
   Mode: Automated
   Timeout: 1800s (30 minutes)
   Output: .paf/PLANNER_OUTPUT.md

[... silence while agent works ...]

✅ Planner agent completed successfully!
```

**When to use:**
- Running in CI/CD pipeline
- Don't need to monitor progress
- Trust the process
- Want minimal terminal noise

---

### Live Mode (Recommended for First Use)

```bash
paf-plan PLAN.md --live
```

**Characteristics:**
- ✅ Real-time output streaming
- ✅ Uses `--dangerously-skip-permissions` (won't hang)
- ✅ See agent's thoughts and actions immediately
- ✅ Know if agent is stuck or making progress
- ⏱️ Can Ctrl+C to cancel if needed

**What you see:**
```
📂 Ensuring .paf directory structure...
📝 Creating planner agent prompt...

🚀 Starting PAF Auto-Planner Agent
🤖 Spawning planner agent...
   Mode: Live
   Timeout: 1800s (30 minutes)

📡 Live output mode - streaming agent activity in real-time
   You'll see everything the agent thinks and does
   Press Ctrl+C to cancel if needed

============================================================

Let me read the PLAN.md file to understand the task...

Reading: /path/to/PLAN.md

I see this is about adding API rate limiting. Let me break this down:
1. Need to analyze existing Express middleware patterns
2. Research rate limiting libraries
3. Design Redis storage approach
...

Creating AGENT_CHARTER.md with 8 agents across 3 waves...

Writing: .paf/AGENT_CHARTER.md
Writing: .paf/DEPENDENCY_DAG.md
Writing: .paf/prompts/AGENT_A1_PROMPT.md
...

✅ All files generated successfully!

============================================================
✅ Planner agent completed successfully!
```

**When to use:**
- First time using auto-planning
- Want to understand how it works
- Debugging or troubleshooting
- Large/complex PLAN.md files
- Not sure if agent is making progress

---

### Interactive Mode

```bash
paf-plan PLAN.md --interactive
```

**Characteristics:**
- ✅ Real-time output streaming
- ⚠️ Asks for permission to read/write files
- ✅ Full control over agent actions
- ⏳ Can pause if waiting for approval
- ⏱️ Can take longer due to approvals

**What you see:**
```
🚀 Starting PAF Auto-Planner Agent
🤖 Spawning planner agent...
   Mode: Interactive

⚠️  IMPORTANT: Running in interactive mode
   You may need to approve file read/write permissions
   The agent will ask before reading files or making changes

Claude wants to read: /path/to/PLAN.md
Allow? (y/n): y

[Agent reads file and shows output]

Claude wants to write: .paf/AGENT_CHARTER.md
Allow? (y/n): y

[Agent writes file]
...
```

**When to use:**
- Need to control what agent can access
- Security-sensitive environments
- Want to review each action before approval
- Learning/educational purposes

---

### Dry Run Mode

```bash
paf-plan PLAN.md --dry-run
```

**Characteristics:**
- ✅ No agent execution
- ✅ Only creates the prompt file
- ✅ Instant completion
- ✅ Safe to run multiple times
- 📝 Review/modify prompt before running

**What you see:**
```
📂 Ensuring .paf directory structure...
📝 Creating planner agent prompt...
   Saved to: .paf/PLANNER_AGENT_PROMPT.md

🚀 PAF Auto-Planner Ready (DRY RUN)

The planner agent prompt has been created at:
   .paf/PLANNER_AGENT_PROMPT.md

To execute manually, run:
   claude -p "$(cat .paf/PLANNER_AGENT_PROMPT.md)"
```

**When to use:**
- Preview the prompt before running
- Modify prompt for custom behavior
- Testing/debugging prompt generation
- Want to run manually later

---

## 🎓 Usage Recommendations

### For Beginners

```bash
# Start with live mode to see how it works
paf-plan PLAN.md --live
```

**Why:** You'll see the agent's reasoning process and understand what gets generated.

### For Production

```bash
# Use automated mode for hands-off execution
paf-plan PLAN.md
```

**Why:** Silent, reliable, won't hang on permissions.

### For Debugging

```bash
# Use live mode to diagnose issues
paf-plan PLAN.md --live

# Or interactive mode for full control
paf-plan PLAN.md --interactive
```

**Why:** Real-time feedback helps identify problems immediately.

### For Customization

```bash
# Generate prompt, modify, then run manually
paf-plan PLAN.md --dry-run
vim .paf/PLANNER_AGENT_PROMPT.md
claude --dangerously-skip-permissions -p "$(cat .paf/PLANNER_AGENT_PROMPT.md)"
```

**Why:** Fine-tune the prompt for specific needs.

---

## 🔧 Combining Options

### Live + Custom Timeout

```bash
# Watch progress with extended timeout
paf-plan PLAN.md --live --timeout 3600
```

### Dry Run + Manual Execution (Live)

```bash
# Generate prompt, then run with live output
paf-plan PLAN.md --dry-run
claude --dangerously-skip-permissions -p "$(cat .paf/PLANNER_AGENT_PROMPT.md)"
```

---

## ⚡ Quick Decision Tree

```
Need to see what's happening?
├─ Yes → Use --live
└─ No → Use default (automated)

Need to control permissions?
├─ Yes → Use --interactive
└─ No → Use --dangerously-skip-permissions (default)

Just want to preview?
├─ Yes → Use --dry-run
└─ No → Run normally

Complex/large PLAN.md?
├─ Yes → Use --live + increase --timeout
└─ No → Use default
```

---

## 🐛 Troubleshooting by Mode

### "Agent seems stuck" (Automated Mode)

**Problem:** Can't see what agent is doing

**Solution:** Re-run with `--live` to see real-time output

```bash
# Instead of:
paf-plan PLAN.md

# Use:
paf-plan PLAN.md --live
```

### "Too much output" (Live Mode)

**Problem:** Terminal flooded with text

**Solution:** Switch to automated mode or redirect to file

```bash
# Silent mode:
paf-plan PLAN.md

# Or save live output to file:
paf-plan PLAN.md --live 2>&1 | tee agent-output.log
```

### "Agent wants permission" (Interactive Mode)

**Problem:** Keep having to approve actions

**Solution:** Use automated mode instead

```bash
# Instead of:
paf-plan PLAN.md --interactive

# Use:
paf-plan PLAN.md  # or --live if you want to watch
```

---

## 📈 Performance Comparison

| Mode | Execution Time | Terminal Output | User Interaction |
|------|---------------|-----------------|------------------|
| Automated | Fastest | Minimal | None |
| Live | Same as automated | Full streaming | None |
| Interactive | Slower | Full streaming | Required |
| Dry Run | Instant | Minimal | None |

---

**Version:** 2.0
**Last Updated:** 2026-01-09
