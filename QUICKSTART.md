# PAF Quick Start Guide

**Get started with Parallel Agent Framework in 5 minutes!**

---

## 🎯 Choose Your Path

### Path 1: Auto-Planned (Fastest) ⚡

**Use when:** You have a clear task description and want AI to set up everything

```bash
# 1. Write PLAN.md
echo "# PLAN: Your Task Here..." > PLAN.md

# 2. Auto-generate setup (5-10 min)
paf-plan PLAN.md

# 3. Execute
paf-spawn "Wave 1" A1 A2 A3  # Check .paf/AGENT_CHARTER.md for agent IDs
```

### Path 2: Manual (Full Control)

**Use when:** You want precise control over agent tasks

```bash
# 1. Initialize
paf-init

# 2. Edit files
vim .paf/AGENT_CHARTER.md      # Define agents
vim .paf/DEPENDENCY_DAG.md     # Map dependencies
vim .paf/prompts/AGENT_A1_PROMPT.md  # Write prompts

# 3. Execute
paf-spawn "Wave 1" A1 A2
```

---

## 📋 Command Reference

```bash
# Setup
paf-init                       # Initialize .paf/ structure
paf-plan PLAN.md               # Auto-generate setup from PLAN.md
paf-plan PLAN.md --dry-run     # Generate prompt only

# Execution
paf-spawn "Wave 1" A1 A2 A3    # Spawn agents in parallel
paf-status                     # Check completion status
paf-validate                   # Validate findings format

# Cleanup
paf-clean                      # Remove findings/status files
```

---

## 📁 Directory Structure

```
your-project/
├── PLAN.md                         ← Your task description (optional)
├── PARALLEL_AGENT_FRAMEWORK.md     ← Framework docs (created by paf-init)
└── .paf/
    ├── AGENT_CHARTER.md            ← Agent roster by wave
    ├── DEPENDENCY_DAG.md           ← Dependencies & wave structure
    ├── prompts/                    ← Agent instruction files
    │   ├── AGENT_A1_PROMPT.md
    │   ├── AGENT_A2_PROMPT.md
    │   └── ...
    ├── findings/                   ← Agent outputs (generated)
    │   ├── A1_FINDINGS.md
    │   ├── A2_FINDINGS.md
    │   └── ...
    └── status/                     ← Completion signals (generated)
        ├── A1_STATUS.md
        ├── A2_STATUS.md
        └── ...
```

---

## ⚡ Auto-Planning Example

### 1. Write PLAN.md

```markdown
# PLAN: Add API Rate Limiting

## Goal
Protect API from abuse with rate limiting

## Requirements
- 100 req/min per IP (basic)
- 1000 req/min for premium users
- Return 429 status when limited
- Store limits in Redis

## Tech Stack
- Node.js + Express
- Redis for storage
```

### 2. Run paf-plan

```bash
paf-plan PLAN.md
```

**Output:**
```
📂 Ensuring .paf directory structure...
📝 Creating planner agent prompt...
   Saved to: .paf/PLANNER_AGENT_PROMPT.md

🚀 Starting PAF Auto-Planner Agent
The agent will analyze your PLAN.md and generate:
   - .paf/AGENT_CHARTER.md
   - .paf/DEPENDENCY_DAG.md
   - .paf/prompts/AGENT_*_PROMPT.md (one per agent)

This will create 5-15 small, focused agents organized into waves.

🤖 Spawning planner agent...
   Timeout: 1800s (30 minutes)
   Output: .paf/PLANNER_OUTPUT.md

✅ Planner agent completed successfully!

✅ PAF Auto-Planning Complete!

Generated files:
   📋 .paf/AGENT_CHARTER.md
   🔀 .paf/DEPENDENCY_DAG.md
   📝 .paf/prompts/AGENT_*_PROMPT.md

Next steps:
   1. Review the generated charter and DAG
   2. Adjust if needed
   3. Run: paf-spawn "Wave 1" <agent-ids>
```

### 3. Review Generated Setup

```bash
# Check what agents were created
cat .paf/AGENT_CHARTER.md

# Example output:
# Wave 1 (4 agents):
#   A1: Analyze current Express middleware patterns
#   A2: Research rate limiting libraries (express-rate-limit, rate-limiter-flexible)
#   A3: Review Redis integration patterns
#   A4: Analyze existing error handling

# Wave 2 (3 agents):
#   A5: Design rate limiter middleware (needs A2, A3)
#   A6: Design Redis storage structure (needs A3)
#   A7: Design error responses for 429 (needs A4)

# Wave 3 (1 agent):
#   A8: Create implementation plan (needs A5, A6, A7)
```

### 4. Execute Waves

```bash
# Wave 1 (independent tasks)
paf-spawn "Wave 1" A1 A2 A3 A4
# Takes ~10 minutes (all run in parallel)

# Check status
paf-status
# ✅ A1: COMPLETE
# ✅ A2: COMPLETE
# ✅ A3: COMPLETE
# ✅ A4: COMPLETE

# Wave 2 (depends on Wave 1)
paf-spawn "Wave 2" A5 A6 A7
# Takes ~15 minutes

# Wave 3 (synthesis)
paf-spawn "Wave 3" A8
# Takes ~15 minutes

# Validate all findings
paf-validate
```

### 5. Synthesize Results

```bash
# Read all findings
cat .paf/findings/A*.md

# Create your implementation plan based on findings
vim IMPLEMENTATION.md
```

---

## 💡 Tips

### Writing Good PLAN.md

**Good:**
```markdown
# PLAN: Feature Name

## Goal
Clear, specific goal statement

## Requirements
- Requirement 1
- Requirement 2

## Tech Stack
- Framework/language
- Key libraries

## Success Criteria
- Measurable outcome 1
- Measurable outcome 2
```

**Bad:**
```markdown
# Make the app better
We need to improve things.
```

### Optimal Agent Count

- **3-5 agents**: Simple tasks, minimal dependencies
- **5-10 agents**: Medium complexity, some dependencies
- **10-15 agents**: Complex tasks, multiple phases

**Too many agents (>15):** Coordination overhead exceeds benefit

### Wave Design

**Good wave structure:**
```
Wave 1: A1, A2, A3, A4 (all independent)
Wave 2: A5, A6 (depend on Wave 1)
Wave 3: A7 (synthesis, depends on Wave 2)
```

**Bad wave structure:**
```
Wave 1: A1
Wave 2: A2 (depends on A1)
Wave 3: A3 (depends on A2)
Wave 4: A4 (depends on A3)
```
↑ This is just sequential work, no parallelization!

---

## 🐛 Common Issues

### "claude: command not found"

Install Claude Code CLI: https://claude.ai/code

### "PAF not installed"

```bash
cd parallel-agent-framework
./install.sh
```

### Agents timing out

Increase timeout in charter or via environment:
```bash
AGENT_TIMEOUT=1200 paf-spawn "Wave 1" A1 A2
```

### Invalid findings format

Check required sections:
- Executive Summary
- Key Findings
- Recommendations
- Confidence Level

---

## 📚 Learn More

- [AUTO_PLANNING.md](./docs/AUTO_PLANNING.md) - Detailed auto-planning guide
- [FRAMEWORK.md](./FRAMEWORK.md) - Complete framework specification
- [EXAMPLES.md](./EXAMPLES.md) - Real-world examples
- [BEST_PRACTICES.md](./docs/BEST_PRACTICES.md) - Tips and anti-patterns

---

## 🎓 Tutorial: Complete Example

Let's implement user authentication from scratch:

```bash
# 1. Setup project
mkdir my-auth-project
cd my-auth-project

# 2. Write plan
cat > PLAN.md << 'EOF'
# PLAN: Add User Authentication

## Goal
Implement complete user auth with login/logout/registration

## Requirements
- User registration (email + password)
- Secure password hashing (bcrypt)
- Session-based auth (express-session)
- Login/logout endpoints
- Protected route middleware
- Frontend login form (React)

## Tech Stack
- Backend: Node.js + Express
- Database: PostgreSQL
- Frontend: React
- Auth: passport.js

## Success Criteria
- Users can register with email/password
- Users can login/logout
- Sessions persist across page reloads
- Passwords are hashed with bcrypt
- Protected routes require auth
EOF

# 3. Auto-generate PAF setup
paf-plan PLAN.md
# Wait 5-10 minutes...

# 4. Review generated setup
cat .paf/AGENT_CHARTER.md
# Shows: 10 agents across 3 waves

# 5. Execute Wave 1 (analysis)
paf-spawn "Wave 1" A1 A2 A3 A4
# Agents analyze:
#   A1: Current user models
#   A2: Auth libraries (passport, bcrypt)
#   A3: API patterns
#   A4: Security practices

# 6. Check status
paf-status
# Wait until all complete (~10 min)

# 7. Execute Wave 2 (design)
paf-spawn "Wave 2" A5 A6 A7 A8
# Agents design:
#   A5: Database schema
#   A6: Auth endpoints
#   A7: Password hashing
#   A8: Session management

# 8. Execute Wave 3 (implementation planning)
paf-spawn "Wave 3" A9 A10
# Agents create:
#   A9: Backend task list
#   A10: Frontend task list

# 9. Validate all findings
paf-validate

# 10. Read findings and implement
cat .paf/findings/A9_FINDINGS.md  # Backend tasks
cat .paf/findings/A10_FINDINGS.md # Frontend tasks

# Now implement following the generated plan!
```

**Total time:** 60-75 minutes (vs 120+ minutes manual)
**Agents spawned:** 10 focused agents
**Waves:** 3 dependency-optimized waves

---

**Version:** 2.0
**Last Updated:** 2026-01-09
