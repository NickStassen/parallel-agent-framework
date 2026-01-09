# PAF Auto-Planning

**NEW FEATURE**: Automatically generate PAF setup from a PLAN.md file using AI!

---

## 🚀 Overview

The `paf-plan` command uses an AI agent to automatically analyze your PLAN.md file and generate:
- `.paf/AGENT_CHARTER.md` - Agent roster organized by waves
- `.paf/DEPENDENCY_DAG.md` - Dependency graph and wave structure
- `.paf/prompts/AGENT_*_PROMPT.md` - Individual agent prompts (5-15 agents)

**Key Benefits:**
- ⚡ **Saves Time**: Eliminates manual PAF setup (reduces setup from 30+ min to 5 min)
- 🎯 **Smart Decomposition**: AI breaks down work into optimal small tasks
- 🔀 **Automatic Waves**: AI organizes tasks by dependencies for maximum parallelization
- 📊 **Many Agents**: Generates 5-15 focused agents (vs typical 3-5 manual)

---

## 📖 Quick Start

### 1. Create PLAN.md

Write a clear description of your task:

```markdown
# PLAN: Add User Authentication

## Goal
Implement a complete user authentication system with login, logout, and session management.

## Requirements
- User registration with email/password
- Secure password storage (hashing)
- Session-based authentication
- Login/logout endpoints
- Protected routes middleware
- Frontend login/logout UI

## Technology Stack
- Backend: Node.js + Express
- Database: PostgreSQL
- Frontend: React

## Success Criteria
- Users can register and login
- Sessions persist across page reloads
- Protected routes require authentication
- Passwords are securely hashed
```

### 2. Run paf-plan

```bash
cd your-project
paf-plan PLAN.md
```

The agent will:
1. Read your PLAN.md
2. Break it down into 5-15 small tasks
3. Organize tasks into dependency waves
4. Generate all PAF files

**Typical execution time:** 5-10 minutes

### 3. Review Generated Files

```bash
# Review agent charter
cat .paf/AGENT_CHARTER.md

# Review dependency graph
cat .paf/DEPENDENCY_DAG.md

# Check agent prompts
ls .paf/prompts/
```

### 4. Execute Waves

```bash
# Wave 1 (check charter for exact agent IDs)
paf-spawn "Wave 1" A1 A2 A3 A4

# Check status
paf-status

# Wave 2 (after Wave 1 completes)
paf-spawn "Wave 2" A5 A6 A7

# Validate
paf-validate
```

---

## 🎯 How It Works

### Task Decomposition Strategy

The planner agent follows this breakdown pattern:

**Analysis Tasks (Wave 1):**
- What exists in the codebase?
- What patterns are used?
- What libraries/frameworks are available?
- What security practices are in place?

**Design Tasks (Wave 2):**
- How should the database schema look?
- What API endpoints are needed?
- What's the authentication flow?
- How should sessions be managed?

**Implementation Planning (Wave 3):**
- What files need to be created/modified?
- What's the implementation order?
- What tests are needed?

### Granularity Target

Each agent task should:
- ✅ Take 5-10 minutes
- ✅ Focus on ONE specific thing
- ✅ Have clear, measurable output
- ✅ Be independent where possible

**Example breakdown for "Add authentication":**

Instead of 1 big agent:
- ❌ Agent 1: "Implement authentication system"

The planner creates 10+ small agents:
- ✅ A1: Analyze current user data models
- ✅ A2: Research auth libraries available
- ✅ A3: Review current API patterns
- ✅ A4: Analyze existing security practices
- ✅ A5: Design user/session database schema (needs A1)
- ✅ A6: Design auth API endpoints (needs A2, A3)
- ✅ A7: Design password hashing strategy (needs A2, A4)
- ✅ A8: Design session management (needs A2, A4)
- ✅ A9: Create backend implementation tasks (needs A5-A8)
- ✅ A10: Create frontend integration tasks (needs A6, A8)

---

## ⚙️ Advanced Usage

### Dry Run Mode

Generate the planner prompt without running the agent:

```bash
paf-plan PLAN.md --dry-run
```

This creates `.paf/PLANNER_AGENT_PROMPT.md` that you can:
- Review before running
- Modify if needed
- Run manually: `claude -p "$(cat .paf/PLANNER_AGENT_PROMPT.md)"`

### Custom Project Directory

```bash
paf-plan /path/to/PLAN.md --project-dir /path/to/project
```

### Custom Timeout

```bash
paf-plan PLAN.md --timeout 3600  # 60 minutes
```

---

## 📊 Example Output

### Generated AGENT_CHARTER.md

```markdown
## 👥 Agent Roster

### Wave 1: Initial Analysis (Spawn Immediately)

| Agent ID | Role | Task | Timeout | Output File |
|----------|------|------|---------|-------------|
| **A1** | Data Modeler | Analyze current user data models | 10min | A1_FINDINGS.md |
| **A2** | Tech Researcher | Research auth libraries (passport, jsonwebtoken) | 10min | A2_FINDINGS.md |
| **A3** | API Analyst | Review current API endpoint patterns | 10min | A3_FINDINGS.md |
| **A4** | Security Auditor | Analyze existing security practices | 10min | A4_FINDINGS.md |

### Wave 2: Design (Spawn After Wave 1)

| Agent ID | Role | Task | Timeout | Depends On | Output File |
|----------|------|------|---------|------------|-------------|
| **A5** | Schema Designer | Design user/session database schema | 15min | A1 | A5_FINDINGS.md |
| **A6** | API Designer | Design authentication endpoints | 15min | A2, A3 | A6_FINDINGS.md |
| **A7** | Security Designer | Design password hashing strategy | 10min | A2, A4 | A7_FINDINGS.md |
| **A8** | Session Designer | Design session management approach | 15min | A2, A4 | A8_FINDINGS.md |

### Wave 3: Implementation Planning (Spawn After Wave 2)

| Agent ID | Role | Task | Timeout | Depends On | Output File |
|----------|------|------|---------|------------|-------------|
| **A9** | Backend Planner | Create backend implementation task list | 15min | A5, A6, A7, A8 | A9_FINDINGS.md |
| **A10** | Frontend Planner | Create frontend integration task list | 15min | A6, A8 | A10_FINDINGS.md |
```

---

## 🔧 Tips for Better Results

### Writing Good PLAN.md

**DO:**
- ✅ Be specific about requirements
- ✅ Mention technology stack
- ✅ Include success criteria
- ✅ List constraints or limitations
- ✅ Reference existing code patterns (if any)

**DON'T:**
- ❌ Be too vague ("make it better")
- ❌ Mix multiple unrelated features
- ❌ Assume knowledge of your codebase structure
- ❌ Skip context about tech choices

### Good PLAN.md Example

```markdown
# PLAN: Implement API Rate Limiting

## Context
Our REST API (Node.js/Express) currently has no rate limiting,
making it vulnerable to abuse. We use Redis for caching.

## Goal
Add rate limiting to protect against abuse while allowing
legitimate high-volume users.

## Requirements
- Limit: 100 requests/minute per IP
- Premium users: 1000 requests/minute (check via API key)
- Return 429 status with Retry-After header
- Store rate limit data in Redis
- Add X-RateLimit-* headers to all responses
- Dashboard to monitor rate limit hits

## Success Criteria
- All endpoints protected
- Premium users can exceed basic limit
- Clear error messages for rate-limited requests
- No performance impact (<5ms overhead)
```

---

## 🚫 Limitations

**When NOT to use paf-plan:**

1. **Very Simple Tasks**: If task takes <15 minutes total, don't use PAF at all
2. **Unclear Requirements**: Agent needs clear direction to decompose effectively
3. **Highly Sequential Work**: If no parallelization is possible, manual approach may be clearer

**Current Limitations:**

- Requires Python 3
- Requires Claude CLI access
- Planning takes 5-10 minutes
- May need manual refinement of generated files

---

## 🔄 Workflow Comparison

### Traditional Manual PAF Setup

```
Time: 30-45 minutes

1. Read PLAN.md (5 min)
2. Brainstorm task breakdown (10 min)
3. Write AGENT_CHARTER.md (10 min)
4. Write DEPENDENCY_DAG.md (5 min)
5. Write 5+ agent prompts (15 min)
6. Execute waves (60 min)

Total: 95-105 minutes
```

### Auto-Planned PAF Setup

```
Time: 5-10 minutes

1. Write PLAN.md (5 min)
2. Run paf-plan PLAN.md (5-10 min auto)
3. Review generated files (5 min)
4. Execute waves (60 min)

Total: 75-80 minutes (20-25% faster!)
```

---

## 🐛 Troubleshooting

### "claude: command not found"

Install Claude Code CLI: https://claude.ai/code

### "Error: PAF not installed"

Run the install script:
```bash
cd parallel-agent-framework
./install.sh
```

### "Agent timed out"

Increase timeout:
```bash
paf-plan PLAN.md --timeout 3600
```

### Generated files don't look right

1. Check your PLAN.md is clear and detailed
2. Run with `--dry-run` and review the prompt
3. Manually edit generated files
4. Provide feedback (we're improving the prompts!)

---

## 📚 Related Documentation

- [FRAMEWORK.md](../FRAMEWORK.md) - Complete PAF specification
- [EXAMPLES.md](../EXAMPLES.md) - Real-world usage examples
- [BEST_PRACTICES.md](./BEST_PRACTICES.md) - Tips for effective PAF use

---

**Version:** 2.0
**Last Updated:** 2026-01-09
**Status:** Beta (Feedback welcome!)
