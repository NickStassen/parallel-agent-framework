# Complete PAF Automation Guide

**From PLAN.md to results in 2 commands!**

---

## 🚀 The Fully Automated Workflow

With `paf-plan` and `paf-auto`, you can go from a task description to complete analysis in just **2 commands**:

```bash
# 1. Generate PAF setup from PLAN.md
paf-plan PLAN.md --live

# 2. Execute all waves automatically
paf-auto --live

# That's it! Results are in .paf/findings/
```

---

## 📖 Complete Example

### Step 1: Create PLAN.md

```bash
cat > PLAN.md << 'EOF'
# PLAN: Add API Rate Limiting

## Goal
Protect our REST API from abuse by implementing rate limiting

## Requirements
- Limit: 100 requests/minute per IP address
- Premium users: 1000 requests/minute (identified by API key)
- Return 429 status code when limit exceeded
- Store rate limit data in Redis
- Add X-RateLimit-* headers to all responses

## Technology Stack
- Backend: Node.js + Express
- Storage: Redis
- Libraries: TBD (need to research)

## Success Criteria
- All endpoints are protected
- Premium users can exceed basic limits
- Clear error messages for rate-limited requests
- No significant performance impact (<5ms overhead)
EOF
```

### Step 2: Auto-Generate PAF Setup

```bash
paf-plan PLAN.md --live
```

**What happens:**
```
📂 Ensuring .paf directory structure...
📝 Creating planner agent prompt...

🚀 Starting PAF Auto-Planner Agent
🤖 Spawning planner agent...
   Mode: Live
   Timeout: 1800s (30 minutes)

📡 Live output mode - streaming agent activity in real-time

============================================================

Reading PLAN.md to understand the task...

Task: Add API Rate Limiting
- Protect REST API from abuse
- 100 req/min per IP, 1000 for premium
- Redis storage, 429 responses
- Express/Node.js stack

Breaking down into small, focused tasks:

Wave 1 (Independent Analysis - 4 agents):
- A1: Analyze existing Express middleware patterns
- A2: Research rate limiting libraries (express-rate-limit, etc)
- A3: Review current Redis integration
- A4: Analyze error handling patterns

Wave 2 (Design - 3 agents):
- A5: Design rate limiter middleware (needs A2, A3)
- A6: Design Redis storage structure (needs A3)
- A7: Design 429 response format (needs A4)

Wave 3 (Planning - 1 agent):
- A8: Create implementation task list (needs A5, A6, A7)

Creating files...
Writing: .paf/AGENT_CHARTER.md ✓
Writing: .paf/DEPENDENCY_DAG.md ✓
Writing: .paf/prompts/AGENT_A1_PROMPT.md ✓
Writing: .paf/prompts/AGENT_A2_PROMPT.md ✓
... (8 total)

============================================================
✅ Planner agent completed successfully!

Generated files:
   📋 .paf/AGENT_CHARTER.md
   🔀 .paf/DEPENDENCY_DAG.md
   📝 .paf/prompts/AGENT_*_PROMPT.md
```

**Time:** ~5-10 minutes

### Step 3: Auto-Execute All Waves

```bash
paf-auto --live
```

**What happens:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 PAF Auto-Executor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reading agent charter: .paf/AGENT_CHARTER.md

Found 3 wave(s) to execute

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Wave 1: Independent Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Agents: A1 A2 A3 A4

========================================
🚀 Starting Independent Analysis
========================================
Agents: A1 A2 A3 A4
Mode: Live (streaming output)

📡 Live output mode - each agent's output is prefixed with [AgentID]

========================================

📝 Spawning Agent A1...
   PID: 12345
📝 Spawning Agent A2...
   PID: 12346
📝 Spawning Agent A3...
   PID: 12347
📝 Spawning Agent A4...
   PID: 12348

⏳ Waiting for all agents to complete...

[A1] Reading server.js to analyze middleware patterns...
[A2] Searching package.json for rate limiting libraries...
[A3] Analyzing Redis client configuration in config/redis.js...
[A4] Reading error handler in middleware/errorHandler.js...
[A1] Found 8 middleware functions using (req, res, next) pattern
[A2] Found express-rate-limit already installed (v5.3.0)
[A3] Redis client using ioredis, connected to localhost:6379
[A1] All middleware use next() for error propagation
[A2] Comparing express-rate-limit vs rate-limiter-flexible...
[A4] Current error handler supports custom status codes
[A3] Redis has TTL support enabled (good for rate limiting)
[A2] Recommendation: express-rate-limit (simpler, already installed)
[A1] ✓ Middleware analysis complete
[A2] ✓ Library research complete
[A3] ✓ Redis analysis complete
[A4] ✓ Error handling analysis complete

✅ Agent A1 completed successfully
✅ Agent A2 completed successfully
✅ Agent A3 completed successfully
✅ Agent A4 completed successfully

========================================
📊 Independent Analysis Results
========================================
✅ All agents completed successfully!


✅ Wave 1 completed successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Wave 2: Design
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Agents: A5 A6 A7

[Similar output for Wave 2 agents...]

✅ Wave 2 completed successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Wave 3: Planning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Agents: A8

[A8 output...]

✅ Wave 3 completed successfully


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Execution Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All 3 wave(s) completed successfully!

Next steps:
  1. paf-validate    - Validate findings format
  2. Review findings in .paf/findings/
  3. Synthesize into final implementation plan
```

**Time:** Variable (depends on complexity, ~30-60 min typical)

### Step 4: Validate and Review

```bash
# Validate findings format
paf-validate

# Review all findings
ls .paf/findings/
cat .paf/findings/A8_FINDINGS.md  # Implementation plan
```

---

## 🎯 What Makes This Automated?

### Traditional PAF Workflow (Manual)

```
1. Read PLAN.md                          (5 min)
2. Brainstorm task breakdown             (10 min)
3. Write AGENT_CHARTER.md                (15 min)
4. Write DEPENDENCY_DAG.md               (5 min)
5. Write 8 agent prompts                 (25 min)
6. Execute Wave 1: paf-spawn "Wave 1" A1 A2 A3 A4
7. Wait and check: paf-status
8. Execute Wave 2: paf-spawn "Wave 2" A5 A6 A7
9. Wait and check: paf-status
10. Execute Wave 3: paf-spawn "Wave 3" A8
11. Validate: paf-validate
────────────────────────────────────────────
Manual effort: ~60 minutes
Execution time: ~30-60 minutes
Total: 90-120 minutes
```

### Fully Automated Workflow

```
1. Write PLAN.md                         (5 min)
2. paf-plan PLAN.md --live              (5-10 min automated)
3. paf-auto --live                       (30-60 min automated)
4. paf-validate                          (1 min)
────────────────────────────────────────────
Manual effort: ~6 minutes
Automation time: ~35-70 minutes
Total: 41-76 minutes

Savings: 50-44 minutes (40-50% faster!)
```

---

## 💡 Key Features

### 1. Reads Charter Automatically

`paf-auto` parses `.paf/AGENT_CHARTER.md` to find:
- Wave names and numbers
- Agent IDs in each wave
- Wave execution order

No manual typing of agent IDs needed!

### 2. Executes Waves in Order

Automatically runs:
- Wave 1 → wait for completion
- Wave 2 → wait for completion
- Wave 3 → wait for completion
- etc.

### 3. Error Handling

If a wave fails:
- Shows which agents failed
- Asks if you want to continue to next wave
- Or stops execution for manual debugging

### 4. Live Output Support

Use `--live` to watch all agents across all waves:
```bash
paf-auto --live
```

Streams output from every agent in every wave!

---

## 🔧 Advanced Usage

### Silent Mode (No Terminal Output)

```bash
# Run completely silently
paf-plan PLAN.md
paf-auto

# Check results when done
paf-validate
```

### Save All Output to Log

```bash
# Capture everything
paf-plan PLAN.md --live 2>&1 | tee planning.log
paf-auto --live 2>&1 | tee execution.log
```

### Stop on First Failure

```bash
# Edit auto_execute_waves.sh or use Ctrl+C when asked to continue
```

### Custom Timeout

```bash
# Set timeout for all agents (in seconds)
AGENT_TIMEOUT=1200 paf-auto --live  # 20 minutes per agent
```

---

## 🐛 Troubleshooting

### "No waves found in AGENT_CHARTER.md"

**Cause:** Charter doesn't have wave sections

**Fix:** Make sure your charter has sections like:
```markdown
### Wave 1: Wave Name
### Wave 2: Wave Name
```

Run `paf-plan` to auto-generate proper format.

### Wave Fails to Execute

**Cause:** Agent prompts missing or malformed

**Check:**
```bash
ls .paf/prompts/
# Should have AGENT_A1_PROMPT.md, AGENT_A2_PROMPT.md, etc.
```

### Want to Skip a Wave

**Solution:** Comment out agents in charter or delete their prompt files

---

## 📊 Comparison Table

| Feature | Manual | Semi-Auto | Fully Auto |
|---------|--------|-----------|------------|
| **Setup time** | 60 min | 5 min | 5 min |
| **Execution** | Manual each wave | Manual each wave | Automatic |
| **Wave transitions** | Manual | Manual | Automatic |
| **Total manual time** | 90-120 min | 40-60 min | 6 min |
| **Control** | Full | High | Low |
| **Best for** | Learning | Debugging | Production |

---

## 🎓 Best Practices

### 1. Always Use --live First Time

```bash
# First time running on new PLAN.md
paf-plan PLAN.md --live
paf-auto --live
```

See how it works before trusting automation.

### 2. Review Charter Before Execution

```bash
# After paf-plan, review what was generated
cat .paf/AGENT_CHARTER.md
vim .paf/AGENT_CHARTER.md  # Make adjustments if needed

# Then execute
paf-auto --live
```

### 3. Use paf-status Between Waves (Manual Mode)

If running waves manually for more control:
```bash
paf-spawn "Wave 1" A1 A2 A3 --live
paf-status  # Check all complete
paf-spawn "Wave 2" A4 A5 --live
```

### 4. Save Logs for Complex Tasks

```bash
mkdir -p logs
paf-auto --live 2>&1 | tee logs/execution-$(date +%Y%m%d-%H%M%S).log
```

---

## 📚 Related Documentation

- [AUTO_PLANNING.md](./AUTO_PLANNING.md) - Auto-planning guide
- [LIVE_MODE_GUIDE.md](./LIVE_MODE_GUIDE.md) - Live output guide
- [QUICKSTART.md](../QUICKSTART.md) - Quick reference
- [FRAMEWORK.md](../FRAMEWORK.md) - Complete framework

---

**Version:** 2.0
**Last Updated:** 2026-01-09
