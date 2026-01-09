# Agent Charter: [Your Task Name]

**Task:** [Task ID/Name]
**Date:** [YYYY-MM-DD]
**Framework:** Parallel Agent Framework v2.0
**Pattern:** [Orchestrator-Worker | Staged Waves | Hybrid]

---

## 🎯 Mission

[1-3 sentence description of the overall goal]

**Success Criteria:**
- ✅ [Criterion 1]
- ✅ [Criterion 2]
- ✅ [Criterion 3]

---

## 👥 Agent Roster

### Wave 1: [Wave Name] (Spawn Immediately)

| Agent ID | Role | Task | Timeout | Output File |
|----------|------|------|---------|-------------|
| **A1** | [Role Name] | [Specific task description] | 15min | A1_FINDINGS.md |
| **A2** | [Role Name] | [Specific task description] | 15min | A2_FINDINGS.md |

**Execution:** Spawn A1, A2 in parallel → wait for all to complete

---

### Wave 2: [Wave Name] (Spawn After Wave 1 Complete)

| Agent ID | Role | Task | Timeout | Depends On | Output File |
|----------|------|------|---------|------------|-------------|
| **A3** | [Role Name] | [Specific task description] | 20min | A1, A2 | A3_FINDINGS.md |

**Execution:** Wait for Wave 1 completion → Spawn A3 → wait for completion

---

## 📊 Task Details

### Agent A1: [Role Name]

**Context Files:**
- `path/to/file1` - [why this file matters]
- `path/to/file2` - [why this file matters]

**Task:**
1. [Specific action 1]
2. [Specific action 2]
3. [Specific action 3]

**Output:** [Expected deliverable]

---

### Agent A2: [Role Name]

**Context Files:**
- `path/to/file3` - [why this file matters]

**Task:**
1. [Specific action 1]
2. [Specific action 2]

**Output:** [Expected deliverable]

---

### Agent A3: [Role Name]

**Context Files:**
- `.paf/findings/A1_FINDINGS.md` - [dependency on A1]
- `.paf/findings/A2_FINDINGS.md` - [dependency on A2]

**Task:**
1. [Specific action 1]
2. [Specific action 2]

**Output:** [Expected deliverable]

---

## ⏱️ Timeline Estimate

| Wave | Agents | Duration | Cumulative |
|------|--------|----------|------------|
| Wave 1 | A1, A2 (parallel) | 15 min | 15 min |
| Wave 2 | A3 | 20 min | 35 min |
| Synthesis | Coordinator | 10 min | **45 min total** |

**Critical Path:** [Longest path through dependency graph]

---

## 🔧 Execution Script

```bash
#!/bin/bash
set -e

PAF_DIR=".paf"
PROMPTS="$PAF_DIR/prompts"
FINDINGS="$PAF_DIR/findings"
STATUS="$PAF_DIR/status"

# Wave 1
echo "=== Starting Wave 1 ==="
timeout 900 claude -p "$(cat $PROMPTS/AGENT_A1_PROMPT.md)" > "$FINDINGS/A1_FINDINGS.md" 2>&1 &
PID_A1=$!
timeout 900 claude -p "$(cat $PROMPTS/AGENT_A2_PROMPT.md)" > "$FINDINGS/A2_FINDINGS.md" 2>&1 &
PID_A2=$!

wait $PID_A1 && echo "COMPLETE" > "$STATUS/A1_STATUS.md" || echo "FAILED:$?" > "$STATUS/A1_STATUS.md"
wait $PID_A2 && echo "COMPLETE" > "$STATUS/A2_STATUS.md" || echo "FAILED:$?" > "$STATUS/A2_STATUS.md"

echo "=== Wave 1 Complete ==="

# Wave 2
echo "=== Starting Wave 2 ==="
timeout 1200 claude -p "$(cat $PROMPTS/AGENT_A3_PROMPT.md)" > "$FINDINGS/A3_FINDINGS.md" 2>&1 &
PID_A3=$!

wait $PID_A3 && echo "COMPLETE" > "$STATUS/A3_STATUS.md" || echo "FAILED:$?" > "$STATUS/A3_STATUS.md"

echo "=== All Waves Complete ==="
```

---

## ✅ Success Criteria

**Overall Mission Success:**
1. ✅ All agents report "COMPLETE" status
2. ✅ All findings files pass format validation
3. ✅ [Specific criterion 1]
4. ✅ [Specific criterion 2]

---

## 🚫 Critical Constraints

**Agents MUST:**
- ❌ NOT [constraint 1]
- ❌ NOT [constraint 2]
- ✅ ALWAYS [requirement 1]
- ✅ ALWAYS [requirement 2]

---

**Charter Status:** [Draft | Ready | Executing | Complete]
**Next Step:** [What happens next]
