# PAF Live Mode Guide

**Watch your agents work in real-time!**

---

## 🎯 Overview

Live mode streams agent output directly to your terminal as they work, so you can:
- ✅ See if agents are making progress
- ✅ Catch errors immediately
- ✅ Understand what agents are thinking
- ✅ Debug issues in real-time
- ✅ Know when agents are stuck

**Available for:**
- `paf-plan` - Watch the planner agent generate your PAF setup
- `paf-spawn` - Watch multiple worker agents execute in parallel

---

## 📖 Usage

### Planning with Live Output

```bash
# Generate PAF setup and watch it happen
paf-plan PLAN.md --live
```

**What you see:**
```
📡 Live output mode - streaming agent activity in real-time

Let me read the PLAN.md file...
Reading: /path/to/PLAN.md

Analyzing task: "Add API Rate Limiting"
Requirements:
- 100 req/min per IP
- Redis storage
- 429 status codes

Breaking down into small tasks:
1. Analyze existing middleware patterns
2. Research rate limiting libraries
3. Design Redis structure
...

Creating AGENT_CHARTER.md with 8 agents across 3 waves...
Writing: .paf/AGENT_CHARTER.md ✓
Writing: .paf/DEPENDENCY_DAG.md ✓
Writing: .paf/prompts/AGENT_A1_PROMPT.md ✓
...

✅ All files generated successfully!
```

### Spawning Agents with Live Output

```bash
# Watch 3 agents work in parallel
paf-spawn "Wave 1" A1 A2 A3 --live
```

**What you see:**
```
========================================
🚀 Starting Wave 1
========================================
Agents: A1 A2 A3
Mode: Live (streaming output)

📡 Live output mode - each agent's output is prefixed with [AgentID]
   Output is also saved to .paf/findings/

========================================

📝 Spawning Agent A1...
   PID: 12345
📝 Spawning Agent A2...
   PID: 12346
📝 Spawning Agent A3...
   PID: 12347

⏳ Waiting for all agents to complete...

[A1] Starting analysis of middleware patterns...
[A2] Reading package.json to find rate limiting libraries...
[A1] Found 5 existing middleware functions in server.js
[A3] Analyzing Redis client configuration...
[A2] Found express-rate-limit and rate-limiter-flexible
[A1] Middleware patterns use (req, res, next) signature
[A2] Comparing features of both libraries...
[A3] Current Redis connection uses ioredis client
[A1] Error handling is done via next(error)
[A2] Recommendation: rate-limiter-flexible (more features)
[A3] Redis is configured for localhost:6379
[A1] ✓ Analysis complete, writing findings...
[A2] ✓ Research complete, writing findings...
[A3] ✓ Analysis complete, writing findings...

✅ Agent A1 completed successfully
✅ Agent A2 completed successfully
✅ Agent A3 completed successfully

========================================
📊 Wave 1 Results
========================================
✅ All agents completed successfully!
```

---

## 🎨 Features

### Color-Coded Output

Each agent gets its own color for easy identification:
- **A1**: Cyan
- **A2**: Yellow
- **A3**: Magenta
- **A4**: Green
- **A5**: Blue
- **A6**: Light Red
- **A7**: Light Green
- **A8**: Light Yellow

Colors cycle if you have more than 8 agents.

### Prefixed Lines

Every line of output is tagged with the agent ID:
```
[A1] Reading file: src/middleware/auth.js
[A2] Analyzing library: express-rate-limit
[A3] Connecting to Redis...
```

This prevents confusion when multiple agents output simultaneously.

### Output Still Saved

Live mode uses `tee` to both:
- Stream to terminal (so you can watch)
- Save to `.paf/findings/` (for later review)

You get the best of both worlds!

---

## 💡 When to Use Live Mode

### ✅ Use Live Mode When:

1. **First time running** - See how it works
2. **Debugging** - Catch errors immediately
3. **Long-running tasks** - Know if agents are progressing
4. **Large PLAN.md** - Monitor complex breakdowns
5. **Uncertain** - Not sure if it will work
6. **Learning** - Understand agent reasoning

### ❌ Skip Live Mode When:

1. **Production/CI/CD** - Don't need terminal output
2. **Scripted workflows** - Output will be logged anyway
3. **Many agents** - Too much output to follow
4. **Background execution** - Not watching anyway

---

## 🔧 Advanced Usage

### Save Live Output to File

```bash
# Watch AND log to file
paf-spawn "Wave 1" A1 A2 A3 --live 2>&1 | tee wave1-output.log
```

### Filter Specific Agent

```bash
# Only show output from A1
paf-spawn "Wave 1" A1 A2 A3 --live 2>&1 | grep "^\[A1\]"
```

### Count Lines Per Agent

```bash
# After execution, see how much each agent output
grep -c "^\[A1\]" wave1-output.log
grep -c "^\[A2\]" wave1-output.log
grep -c "^\[A3\]" wave1-output.log
```

---

## 🐛 Troubleshooting

### Output is Overwhelming

**Problem:** Too many agents outputting at once

**Solutions:**
```bash
# 1. Run fewer agents per wave
paf-spawn "Wave 1A" A1 A2 --live
paf-spawn "Wave 1B" A3 A4 --live

# 2. Use silent mode
paf-spawn "Wave 1" A1 A2 A3

# 3. Follow specific agent
tail -f .paf/findings/A1_FINDINGS.md
```

### Colors Don't Show

**Problem:** Terminal doesn't support colors

**Solution:** Colors are ANSI codes, most modern terminals support them. If not:
```bash
# Redirect without color codes (they'll show as text)
paf-spawn "Wave 1" A1 A2 --live | cat
```

### Output is Interleaved/Messy

**Problem:** Multiple agents writing at same time creates mixed lines

**Explanation:** This is normal! When 3+ agents output simultaneously, lines may interleave:
```
[A1] Starting anal[A2] Reading file...[A1]ysis...
```

**Solutions:**
```bash
# 1. Run fewer agents in parallel
# 2. Check individual findings files after completion
cat .paf/findings/A1_FINDINGS.md

# 3. Use silent mode if readability is critical
paf-spawn "Wave 1" A1 A2 A3  # No --live
```

---

## 📊 Comparison: Live vs Silent

| Aspect | Live Mode | Silent Mode |
|--------|-----------|-------------|
| **Terminal output** | Real-time stream | Minimal status messages |
| **Progress visibility** | High | Low |
| **Debugging** | Easy | Hard (must check files) |
| **Performance** | Same | Same |
| **Output saved** | Yes (via `tee`) | Yes |
| **CI/CD friendly** | No | Yes |
| **Readability** | Can be messy with many agents | Clean status updates |

---

## 🎓 Example Workflows

### Workflow 1: Planning + Execution

```bash
# 1. Generate PAF setup with live output
paf-plan PLAN.md --live

# 2. Review generated files
cat .paf/AGENT_CHARTER.md

# 3. Execute waves with live output
paf-spawn "Wave 1" A1 A2 A3 A4 --live
paf-spawn "Wave 2" A5 A6 --live
paf-spawn "Wave 3" A7 --live

# 4. Validate
paf-validate
```

### Workflow 2: Debug Agent Issues

```bash
# Agent A3 failed in previous run, re-run with live output
paf-spawn "Wave 1 Retry" A3 --live

# Watch what goes wrong in real-time
# Fix issue based on live output
# Re-run
```

### Workflow 3: Monitor Long-Running Agents

```bash
# Start wave with live output
paf-spawn "Wave 1" A1 A2 A3 A4 A5 --live 2>&1 | tee wave1.log

# In another terminal, follow specific agent
tail -f .paf/findings/A3_FINDINGS.md

# Check status periodically
paf-status
```

---

## 🎯 Best Practices

### 1. Start with Live Mode

Always use `--live` the first time:
```bash
paf-plan PLAN.md --live           # First time
paf-spawn "Wave 1" A1 A2 --live   # First time
```

### 2. Switch to Silent for Production

Once you trust it works:
```bash
paf-plan PLAN.md          # No --live
paf-spawn "Wave 1" A1 A2  # No --live
```

### 3. Use Live for Debugging

If something fails:
```bash
# Re-run failed agent with live output
paf-spawn "Retry" A3 --live
```

### 4. Save Logs for Complex Runs

```bash
# Save live output for later analysis
paf-spawn "Wave 1" A1 A2 A3 A4 A5 --live 2>&1 | tee logs/wave1-$(date +%Y%m%d-%H%M%S).log
```

### 5. Limit Agents in Live Mode

For readability, run max 5 agents with `--live`:
```bash
# Good: 3 agents
paf-spawn "Wave 1" A1 A2 A3 --live

# Okay: 5 agents
paf-spawn "Wave 1" A1 A2 A3 A4 A5 --live

# Too many: 10 agents (use silent or split into waves)
paf-spawn "Wave 1A" A1 A2 A3 --live
paf-spawn "Wave 1B" A4 A5 A6 --live
```

---

## 📚 Related Documentation

- [AUTO_PLANNING.md](./AUTO_PLANNING.md) - Auto-planning guide
- [PAF_MODES_COMPARISON.md](./PAF_MODES_COMPARISON.md) - Mode comparison
- [FRAMEWORK.md](../FRAMEWORK.md) - Complete PAF specification

---

**Version:** 2.0
**Last Updated:** 2026-01-09
