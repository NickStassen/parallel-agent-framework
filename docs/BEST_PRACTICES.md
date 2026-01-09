# Best Practices for Parallel Agent Framework

Tips, guidelines, and lessons learned from using PAF effectively.

---

## 🎯 Task Decomposition

### ✅ DO

**Create 3-7 independent tasks**
```
Good:
- A1: Analyze database schema
- A2: Review API endpoints
- A3: Audit security measures
```

**Each task takes 5-20 minutes**
- Too short (<5 min): Overhead exceeds benefit
- Too long (>20 min): Risk of timeout, hard to parallelize

**Define clear outputs**
```
Good: "Create table of all metrics with sample counts"
Bad:  "Look at metrics"
```

**Front-load independent work**
```
Good:
Wave 1: A1, A2, A3 (all independent)
Wave 2: A4 (depends on A1, A2, A3)

Bad:
Wave 1: A1
Wave 2: A2 (depends on A1)
Wave 3: A3 (depends on A2)
```

### ❌ DON'T

**Create dependency chains**
```
Bad: A1 → A2 → A3 → A4 (no parallelism)
```

**Give vague mandates**
```
Bad: "Investigate the codebase"
Good: "Find all usages of deprecated API in src/ directory"
```

**Create overlapping tasks**
```
Bad:
- A1: "Analyze authentication"
- A2: "Review security" ← Overlaps with A1
```

**Exceed 7 agents**
- Coordination overhead grows exponentially
- Synthesis becomes unwieldy
- Consider hierarchical approach instead

---

## 📝 Agent Prompts

### ✅ DO

**List exactly which files to read**
```markdown
## Context Files (READ ONLY THESE)
- `src/auth/login.py` - Login endpoint implementation
- `src/auth/session.py` - Session management
- `tests/test_auth.py` - Authentication tests
```

**Enforce strict output format**
```markdown
## Output Format (STRICTLY FOLLOW)
[Provide exact template with required sections]
```

**Include success criteria**
```markdown
## Success Criteria
- [ ] All endpoints cataloged
- [ ] Sample requests provided
- [ ] Security issues flagged
```

**Set time budget**
```markdown
## Time Budget
15 minutes maximum. Prioritize:
1. Critical security findings (5 min)
2. Breaking changes (5 min)
3. Nice-to-have improvements (5 min)
```

### ❌ DON'T

**Give unlimited context**
```
Bad: "Read the entire codebase"
Good: "Read these 5 specific files"
```

**Use free-form outputs**
```
Bad: "Write what you find"
Good: [Structured template with sections]
```

**Create circular dependencies**
```
Bad: A1 reads A2_FINDINGS.md, A2 reads A1_FINDINGS.md
```

---

## 🔄 Wave Execution

### ✅ DO

**Check status before proceeding**
```bash
if [ "$(cat .paf/status/A1_STATUS.md)" != "COMPLETE" ]; then
    echo "ERROR: A1 failed, cannot proceed"
    exit 1
fi
```

**Use timeouts on all spawns**
```bash
timeout 600 claude -p "..." > output.md 2>&1
```

**Retry critical agents once**
```bash
if [ $exit_code -ne 0 ]; then
    echo "Retrying A1..."
    timeout 600 claude -p "..." > output.md 2>&1
fi
```

**Redirect stderr to files**
```bash
> "$FINDINGS/A1_FINDINGS.md" 2>&1
```
This captures errors in findings file for debugging

### ❌ DON'T

**Proceed without validation**
```
Bad:
spawn_wave "Wave 1" A1 A2
spawn_wave "Wave 2" A3  # Might run even if Wave 1 failed
```

**Forget timeouts**
```
Bad: claude -p "..." > output.md  # Can hang forever
Good: timeout 600 claude -p "..." > output.md
```

**Ignore exit codes**
```
Bad:
claude -p "..." > output.md
# Continue regardless of failure
```

---

## 📊 Validation & Synthesis

### ✅ DO

**Validate all findings before synthesis**
```bash
for findings in .paf/findings/*.md; do
    if ! grep -q "## Executive Summary" "$findings"; then
        echo "Invalid: $findings missing Executive Summary"
        exit 1
    fi
done
```

**Flag conflicting recommendations**
```markdown
## Conflicts
- A1 recommends: Use PostgreSQL
- A2 recommends: Use MongoDB
- Resolution: [Coordinator decision with rationale]
```

**Note missing coverage**
```markdown
## Gaps
- No agent analyzed caching layer
- Security audit incomplete (A4 timed out)
- Recommendation: Add A5 for caching analysis
```

**Require confidence levels**
```markdown
## Confidence Level
HIGH - Directly queried database, results are factual
```

### ❌ DON'T

**Accept invalid formats**
```
Bad: Agent outputs free text, synthesis is impossible
```

**Ignore low confidence findings**
```
Bad: Treat "LOW confidence, needs investigation" same as "HIGH confidence"
```

**Synthesize prematurely**
```
Bad: Start synthesis while agents still running
```

---

## 🚨 Error Handling

### ✅ DO

**Classify agent criticality**
```yaml
Critical:
  - A1: Database schema (MUST have for A4)
  - A3: Metrics validation (MUST have for A2)

Non-Critical:
  - A4: Blackbox diagnostics (nice-to-have)
```

**Provide fallbacks**
```bash
if [ "$(cat .paf/status/A4_STATUS.md)" != "COMPLETE" ]; then
    echo "A4 failed, using default config"
    cp defaults/config.yaml .paf/findings/A4_FINDINGS.md
fi
```

**Log failures clearly**
```bash
echo "FAILED: Agent A3 timed out after 600s" > .paf/status/A3_STATUS.md
docker logs container | tail -100 >> .paf/status/A3_STATUS.md
```

### ❌ DON'T

**Treat all failures equally**
```
Bad: A1 fails (critical) → abort
      A4 fails (nice-to-have) → abort

Good: A1 fails → retry, then abort
      A4 fails → note in synthesis, proceed
```

**Fail silently**
```
Bad: Agent fails, no log, no status file
Good: Status file + error logs + coordinator notification
```

---

## ⚡ Performance Optimization

### ✅ DO

**Use appropriate timeouts**
```
Simple analysis: 300s (5 min)
Complex analysis: 900s (15 min)
Multi-step tasks: 1200s (20 min)
```

**Minimize agent context**
```
Good: 10-50 files explicitly listed
Bad: "Read entire src/ directory" (100+ files)
```

**Cache repeated work**
```
If multiple agents need same data:
Wave 1: A1 gathers data
Wave 2: A2, A3 read A1's findings (not raw data)
```

### ❌ DON'T

**Set timeout too low**
```
Bad: 60s for complex analysis → timeout
Good: 600s with "focus on highest priority" guidance
```

**Let agents repeat work**
```
Bad:
A1: Fetch all API endpoints
A2: Fetch all API endpoints (duplicate)

Good:
A1: Fetch all API endpoints
A2: Read A1_FINDINGS.md for endpoints
```

---

## 📏 Sizing Guidelines

### 3 Agents (Simple)
```
Duration: 20-30 min
Use case: Quick analysis, simple design
Example: Audit 3 config files in parallel
```

### 4-5 Agents (Medium)
```
Duration: 40-60 min
Use case: Moderate complexity, some dependencies
Example: Feature design (DB + API + Frontend + Tests)
```

### 6-7 Agents (Complex)
```
Duration: 60-90 min
Use case: Comprehensive analysis, multiple waves
Example: Full system refactoring plan
```

### >7 Agents (Too Many)
```
Consider:
1. Merging related tasks
2. Hierarchical approach (meta-PAF)
3. Multiple PAF sessions
```

---

## 🎓 Lessons Learned

### Lesson 1: Explicit is Better Than Implicit

**Bad:** "A2 will use metrics from A3"
**Good:**
```markdown
## Context Files
- `.paf/findings/A3_FINDINGS.md` - Metrics validation table
```

### Lesson 2: Fail Fast on Critical Dependencies

**Bad:** Let Wave 2 run even if Wave 1 had critical failures
**Good:** Validate Wave 1 completion, abort if critical agents failed

### Lesson 3: One Agent, One File

**Bad:** All agents write to `FINDINGS.md` → race conditions
**Good:** Each agent writes to `A1_FINDINGS.md`, `A2_FINDINGS.md`, etc.

### Lesson 4: Timeouts Prevent Hangs

**Bad:** No timeout → agent hangs → entire wave blocked
**Good:** 10-minute timeout → agent killed → retry or skip → wave completes

### Lesson 5: Validation Before Synthesis

**Bad:** Synthesize malformed outputs → garbage results
**Good:** Validate format → retry invalid agents → then synthesize

### Lesson 6: Confidence Matters

**Bad:** Treat all findings equally
**Good:** Weight HIGH confidence findings more than LOW

### Lesson 7: Gaps Are OK

**Bad:** Try to cover everything, add 10+ agents
**Good:** Cover critical areas with 6 agents, note gaps for follow-up

---

## 🔍 Debugging PAF Executions

### Check Agent Status
```bash
cat .paf/status/A1_STATUS.md
# Expected: COMPLETE | FAILED | TIMEOUT
```

### Read Agent Findings
```bash
cat .paf/findings/A1_FINDINGS.md
# Look for: Executive Summary, Key Findings, Confidence Level
```

### Check for Hangs
```bash
ps aux | grep claude
# If agents still running after timeout, kill them
```

### Validate Findings Format
```bash
grep -q "## Executive Summary" .paf/findings/A1_FINDINGS.md
echo $?  # 0 = found, 1 = missing
```

### Review Wave Timing
```bash
ls -lt .paf/findings/
# Check timestamps to see if agents ran in parallel or sequential
```

---

## ✅ Quality Checklist

Before considering PAF execution successful:

- [ ] All critical agents completed (status = COMPLETE)
- [ ] All findings files have required sections
- [ ] No conflicting recommendations (or conflicts resolved)
- [ ] Confidence levels provided for all findings
- [ ] Gaps identified and documented
- [ ] Final plan is actionable and specific
- [ ] Estimated vs actual time within 20%
- [ ] No agents timed out (or timeouts were handled)
