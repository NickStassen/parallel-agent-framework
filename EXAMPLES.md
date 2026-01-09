# Parallel Agent Framework - Examples

Real-world examples of using PAF for different types of tasks.

---

## Example 1: VCT Alerting System (Monitoring Configuration)

**Task:** Fix broken INFO alerts and add 4 new alerts to populate Slack #ops-info channel

**Agents:** 6 agents across 3 waves

### Agent Breakdown

**Wave 1 (Independent):**
- **A1:** Fix ServiceRecovered alert logic (analyze broken query, design fix)
- **A3:** Validate Prometheus/Loki metrics (SSH to server, query all metrics)
- **A4:** Diagnose blackbox ICMP issue (investigate why metrics missing)

**Wave 2 (Dependent on Wave 1):**
- **A2:** Design 4 INFO alerts using validated metrics from A3
- **A5:** Optimize alert policies (calculate frequency, tune intervals)

**Wave 3 (Testing):**
- **A6:** Create comprehensive testing plan for all alerts

### Results
- **Time:** 55 minutes parallel (vs 100 minutes sequential)
- **Deliverable:** Complete YAML for 5 alerts + testing plan + rollback procedure
- **Success:** All alerts deployed and firing within 1 hour

### Key Learnings
- Metrics validation (A3) prevented designing alerts for non-existent metrics
- Parallel diagnostics (A4) identified blackbox issue without blocking other work
- Wave structure ensured A2 had validated metrics before designing alerts

---

## Example 2: API Refactoring (Code Transformation)

**Task:** Refactor legacy REST API to GraphQL

**Agents:** 5 agents across 2 waves

### Agent Breakdown

**Wave 1 (Analysis):**
- **A1:** Catalog all REST endpoints (methods, routes, payloads)
- **A2:** Analyze database schema and relationships
- **A3:** Map authentication/authorization flows
- **A4:** Identify breaking changes and migration risks

**Wave 2 (Design):**
- **A5:** Design unified GraphQL schema (using findings from A1-A4)

### Why PAF Worked
- **Parallel analysis:** 4 independent analysis tasks completed in 20 minutes
- **Context isolation:** Each agent focused on specific aspect without confusion
- **Synthesis:** A5 had complete picture from all angles to design optimal schema

---

## Example 3: Performance Debugging (Investigation)

**Task:** Identify and fix application slowdown in production

**Agents:** 4 agents, all parallel (Wave 1 only)

### Agent Breakdown

**Wave 1 (Parallel Investigation):**
- **A1:** Analyze application logs for errors/patterns
- **A2:** Profile database queries (slow queries, N+1 problems)
- **A3:** Review caching layer (hit rates, evictions, misconfigurations)
- **A4:** Examine infrastructure metrics (CPU, memory, network)

**Synthesis:**
Coordinator identified root cause by correlating findings:
- A1: Spike in requests at specific times
- A2: Unoptimized query on new feature
- A3: Cache bypass due to query parameter variation
- A4: Database CPU spiked during request spikes

**Solution:** Add query optimization + cache key normalization

### Why PAF Worked
- **Exhaustive parallel search:** Investigated all potential causes simultaneously
- **Speed:** Found root cause in 15 minutes (would take 60+ minutes sequentially)
- **No tunnel vision:** Avoided prematurely focusing on wrong hypothesis

---

## Example 4: Documentation Sprint (Content Creation)

**Task:** Create complete API documentation for new service

**Agents:** 6 agents across 2 waves

### Agent Breakdown

**Wave 1 (Content Generation):**
- **A1:** Write Getting Started guide
- **A2:** Document all API endpoints (OpenAPI spec)
- **A3:** Create authentication guide
- **A4:** Write deployment guide
- **A5:** Create troubleshooting guide

**Wave 2 (Integration):**
- **A6:** Create unified documentation site structure (using all guides from Wave 1)

### Results
- **Time:** 40 minutes (vs 120+ minutes sequential)
- **Output:** 5 complete guides + integrated documentation site
- **Quality:** Each agent focused on one topic, resulting in depth and consistency

---

## Example 5: Feature Implementation Planning (Design)

**Task:** Design implementation plan for user authentication system

**Agents:** 5 agents across 2 waves

### Agent Breakdown

**Wave 1 (Component Design):**
- **A1:** Design database schema (users, sessions, tokens tables)
- **A2:** Design API endpoints (login, logout, refresh, validate)
- **A3:** Design frontend flows (login form, session management, redirects)
- **A4:** Design security measures (password hashing, CSRF, rate limiting)

**Wave 2 (Integration):**
- **A5:** Create unified implementation plan (order of tasks, dependencies)

### Why PAF Worked
- **Parallel expertise:** Each agent designed one system component
- **Comprehensive:** All aspects covered simultaneously
- **Coordinated:** A5 synthesized into coherent implementation order

---

## Common Patterns Across Examples

### Pattern 1: Analysis → Design → Testing
1. **Wave 1:** Parallel analysis of different aspects
2. **Wave 2:** Design solution using consolidated analysis
3. **Wave 3:** Create testing/validation plan

**Use for:** Feature implementation, architecture changes

### Pattern 2: All-Parallel Investigation
1. **Wave 1:** All agents investigate different potential causes/areas
2. **Synthesis:** Coordinator identifies root cause from correlated findings

**Use for:** Debugging, troubleshooting, performance investigation

### Pattern 3: Content Creation → Integration
1. **Wave 1:** Each agent creates independent content piece
2. **Wave 2:** Integrate all pieces into cohesive whole

**Use for:** Documentation, reports, multi-part deliverables

---

## Anti-Patterns (What NOT to Do)

### ❌ Anti-Pattern 1: Deep Dependency Chains
```
A1 → A2 → A3 → A4 → A5
```
**Problem:** Serializes execution, no parallelism benefit
**Solution:** Find independent subtasks, create broader waves

### ❌ Anti-Pattern 2: Too Many Agents
```
10+ agents with complex dependencies
```
**Problem:** Coordination overhead exceeds parallelism benefit
**Solution:** Keep to 3-7 agents, merge related tasks

### ❌ Anti-Pattern 3: Overlapping Responsibilities
```
A1: "Analyze authentication"
A2: "Analyze security"  ← Overlaps with A1
```
**Problem:** Duplicate work, conflicting findings
**Solution:** Clear boundaries, non-overlapping mandates

### ❌ Anti-Pattern 4: Vague Tasks
```
A1: "Research the codebase"
```
**Problem:** Agent doesn't know what success looks like
**Solution:** Specific task with measurable output

---

## Sizing Guidelines

### Small Task (3 agents, 1 wave, 30 min)
- Simple analysis or design
- Minimal dependencies
- Quick turnaround needed

### Medium Task (4-5 agents, 2 waves, 60 min)
- Moderate complexity
- Some dependencies
- Balanced analysis and design

### Large Task (6-7 agents, 3 waves, 90 min)
- High complexity
- Multiple dependencies
- Comprehensive coverage needed

### Too Large (>7 agents)
- Consider breaking into multiple PAF sessions
- Or use hierarchical approach (meta-agent coordinates sub-PAF sessions)

---

## Templates by Use Case

### Debugging Template
```
Wave 1 (Parallel Investigation):
- A1: Analyze logs
- A2: Profile performance
- A3: Review recent changes
- A4: Check infrastructure

Synthesis: Identify root cause, propose fix
```

### Feature Design Template
```
Wave 1 (Component Design):
- A1: Database/storage design
- A2: API design
- A3: Frontend design
- A4: Security/auth design

Wave 2 (Integration):
- A5: Implementation plan with dependencies
```

### Documentation Template
```
Wave 1 (Content Creation):
- A1: Getting started
- A2: API reference
- A3: Deployment guide
- A4: Examples/tutorials

Wave 2 (Integration):
- A5: Unified docs site structure
```

---

## Success Metrics

Track these metrics to evaluate PAF effectiveness:

1. **Time Savings:** Sequential time vs parallel time
2. **Quality:** Were findings comprehensive and accurate?
3. **Dependencies:** Did wave structure minimize blocking?
4. **Coverage:** Were all aspects of task addressed?
5. **Synthesis:** Was final plan cohesive and actionable?

**Good indicators:**
- >30% time reduction vs sequential
- Minimal agent failures/retries
- Clear, non-conflicting findings
- Actionable final deliverable

**Warning signs:**
- Frequent agent failures
- Conflicting findings requiring extensive reconciliation
- Agents completing in <5 minutes (task too simple)
- Agents timing out (task too complex)
