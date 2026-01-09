# Task Dependency Graph

**Task:** [Your Task Name]
**Framework:** Parallel Agent Framework v2.0

---

## Dependency Visualization

```
Wave 1 (Independent)
┌────────┐  ┌────────┐
│   A1   │  │   A2   │
└────┬───┘  └────┬───┘
     │           │
     └─────┬─────┘
           ▼
      ┌────────┐
      │   A3   │
      └────────┘
```

---

## Wave 1: [Wave Name] (Spawn Immediately)

| Agent | Task | Depends On | Blocks | Timeout | Critical? |
|-------|------|------------|--------|---------|-----------|
| **A1** | [Task description] | None | A3 | 15min | YES |
| **A2** | [Task description] | None | A3 | 15min | YES |

**Spawn Command:**
```bash
timeout 900 claude -p "$(cat .paf/prompts/AGENT_A1_PROMPT.md)" > .paf/findings/A1_FINDINGS.md 2>&1 &
timeout 900 claude -p "$(cat .paf/prompts/AGENT_A2_PROMPT.md)" > .paf/findings/A2_FINDINGS.md 2>&1 &
wait
```

**Failure Handling:**
- **A1 fails:** CRITICAL - Retry once, abort if still fails
- **A2 fails:** CRITICAL - Retry once, abort if still fails

---

## Wave 2: [Wave Name] (Spawn After Wave 1 Complete)

| Agent | Task | Depends On | Blocks | Timeout | Critical? |
|-------|------|------------|--------|---------|-----------|
| **A3** | [Task description] | A1, A2 | None | 20min | YES |

**Wait Condition:**
```bash
if [ "$(cat .paf/status/A1_STATUS.md)" == "COMPLETE" ] && \
   [ "$(cat .paf/status/A2_STATUS.md)" == "COMPLETE" ]; then
    echo "Wave 1 complete, starting Wave 2"
else
    echo "ERROR: Critical Wave 1 agents failed"
    exit 1
fi
```

**Spawn Command:**
```bash
timeout 1200 claude -p "$(cat .paf/prompts/AGENT_A3_PROMPT.md)" > .paf/findings/A3_FINDINGS.md 2>&1
```

**Failure Handling:**
- **A3 fails:** CRITICAL - Retry once, abort if still fails

---

## Execution Order Summary

```
Time 0:     Spawn A1, A2 (parallel)
Time +15m:  Wave 1 complete ✓
            Spawn A3
Time +35m:  Wave 2 complete ✓
            Begin synthesis
Time +45m:  FINAL_PLAN ready
```

---

## Critical Path Analysis

**Longest Path:**
```
[A1 or A2] (15min) → A3 (20min) = 35 minutes
```

**Parallel Efficiency:**
- Sequential: 15 + 15 + 20 = 50 minutes
- Parallel: 15 + 20 = 35 minutes
- **Time saved: 15 minutes (30% reduction)**

---

## Dependency Rationale

### Why A3 depends on A1
**Reason:** [Explain dependency]
**Risk if violated:** [Consequence]

### Why A3 depends on A2
**Reason:** [Explain dependency]
**Risk if violated:** [Consequence]

---

## Failure Impact Matrix

| Failed Agent | Impact | Mitigation |
|--------------|--------|------------|
| A1 | CRITICAL - [Consequence] | Retry once, abort if fails |
| A2 | CRITICAL - [Consequence] | Retry once, abort if fails |
| A3 | CRITICAL - [Consequence] | Retry once, abort if fails |

---

**DAG Status:** [Draft | Validated | Executing]
**Parallelization:** [X] waves with [Y] total agents
**Critical Path:** [Z] minutes
