#!/usr/bin/env python3
"""
PAF Auto Planner - Automatically generate .paf structure from PLAN.md

This tool uses an agent to analyze a PLAN.md file and automatically:
1. Break down the plan into small, independent tasks (1 task = 1 agent)
2. Organize tasks into dependency waves
3. Generate AGENT_CHARTER.md
4. Generate DEPENDENCY_DAG.md
5. Generate all AGENT_*_PROMPT.md files

Usage:
    python paf_auto_planner.py <path-to-PLAN.md> [--project-dir <dir>] [--dry-run]
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path


PLANNER_AGENT_PROMPT = """# PAF Auto-Planner Agent

## Your Mission
Analyze the provided PLAN.md file and automatically generate a complete Parallel Agent Framework (PAF) setup with many small, focused agents organized into dependency waves.

## Critical Requirements
1. **Small Task Granularity**: Break down work into VERY small tasks - each task should take 5-10 minutes
2. **1 Agent = 1 Task**: Assign exactly one agent per task (no shared tasks)
3. **Many Agents**: Aim for 5-15 agents total (more is better for parallelization)
4. **Smart Waves**: Group independent tasks in the same wave, dependent tasks in later waves
5. **Clear Dependencies**: Only create dependencies when truly necessary (data from one task needed by another)

## Context Files You MUST Read First

Before starting, read these files to understand the templates:
1. `{framework_root}/templates/AGENT_CHARTER_TEMPLATE.md` - Template for AGENT_CHARTER.md
2. `{framework_root}/templates/DEPENDENCY_DAG_TEMPLATE.md` - Template for DEPENDENCY_DAG.md
3. `{framework_root}/templates/AGENT_PROMPT_TEMPLATE.md` - Template for agent prompts

## Your Task

### Step 1: Read and Analyze PLAN.md
- Read the PLAN.md file at: {plan_path}
- Understand the overall goal and required work
- Identify all discrete pieces of work that need to be done

### Step 2: Break Down Into Small Tasks
- Decompose the work into 5-15 small, focused tasks
- Each task should be:
  - Completable in 5-10 minutes
  - Focused on ONE specific thing (analysis, design, implementation, testing, etc.)
  - Independent where possible
  - Have a clear, measurable output

**Examples of good task granularity:**
- ❌ BAD: "Implement authentication system" (too big)
- ✅ GOOD: "Design user database schema"
- ✅ GOOD: "Design login API endpoint structure"
- ✅ GOOD: "Design password hashing strategy"
- ✅ GOOD: "Design session management approach"

### Step 3: Identify Dependencies
- Map which tasks depend on outputs from other tasks
- Only create dependencies when Task B truly NEEDS the output of Task A
- Group independent tasks together in early waves
- Create as much parallelism as possible

### Step 4: Generate PAF Files
Generate the following files in the `{project_dir}/.paf/` directory:

#### A. AGENT_CHARTER.md
- Follow the template structure exactly
- Include all agents organized by wave
- Provide clear role and task for each agent
- Set appropriate timeouts (5-15 minutes per agent)

#### B. DEPENDENCY_DAG.md
- Follow the template structure exactly
- Map all dependencies clearly
- Show wave structure
- Include visualization diagram

#### C. Individual Agent Prompts (`.paf/prompts/AGENT_<ID>_PROMPT.md`)
- Create one prompt file per agent
- Follow the AGENT_PROMPT_TEMPLATE.md structure
- Be VERY specific about:
  - Context files to read (from the project)
  - Exact task steps
  - Expected output format
  - Time budget

## Output Format

You must create the following files in the project directory:

```
{project_dir}/.paf/
├── AGENT_CHARTER.md
├── DEPENDENCY_DAG.md
└── prompts/
    ├── AGENT_A1_PROMPT.md
    ├── AGENT_A2_PROMPT.md
    ├── AGENT_A3_PROMPT.md
    └── ... (one per agent)
```

## Important Guidelines

### Task Decomposition Strategy
1. **Analysis Tasks**: What exists? What's the current state?
2. **Design Tasks**: How should it work? What's the approach?
3. **Implementation Tasks**: What code changes are needed?
4. **Testing Tasks**: How do we verify it works?
5. **Documentation Tasks**: What docs need updating?

### Wave Organization Strategy
- **Wave 1**: All independent analysis/investigation tasks
- **Wave 2**: Design tasks that need analysis results
- **Wave 3**: Implementation planning that needs design
- **Wave 4**: Testing/validation planning (if needed)

### Context File Selection
For each agent, identify the SPECIFIC files they need to read:
- Source code files relevant to their task
- Configuration files
- Documentation
- Previous agent findings (if dependent)

**DO NOT** give agents access to the entire codebase - be surgical.

## Example Task Breakdown

**Original Plan:** "Add user authentication"

**Good Breakdown (10 agents, 3 waves):**

**Wave 1 (Independent Analysis):**
- A1: Analyze current user data models
- A2: Research auth libraries and frameworks available
- A3: Analyze existing API endpoint patterns
- A4: Review current security practices in codebase

**Wave 2 (Design, depends on Wave 1):**
- A5: Design user/session database schema (needs A1)
- A6: Design authentication API endpoints (needs A2, A3)
- A7: Design password security strategy (needs A2, A4)
- A8: Design session management approach (needs A2, A4)

**Wave 3 (Implementation Planning, depends on Wave 2):**
- A9: Create backend implementation task list (needs A5, A6, A7, A8)
- A10: Create frontend integration task list (needs A6, A8)

## Success Criteria
- [ ] Generated AGENT_CHARTER.md with 5-15 agents
- [ ] Generated DEPENDENCY_DAG.md with clear wave structure
- [ ] Generated one AGENT_*_PROMPT.md per agent
- [ ] Each agent has a small, focused task (5-10 min)
- [ ] Dependencies are minimal and necessary
- [ ] Maximum parallelization achieved
- [ ] All files follow template formats exactly

## Time Budget
30 minutes maximum. Focus on creating a comprehensive breakdown.

---
**BEGIN WORK NOW.** Start by reading the PLAN.md file at {plan_path}, then generate all PAF files.
"""


def get_framework_root():
    """Find the framework root directory."""
    script_dir = Path(__file__).parent
    return script_dir.parent


def ensure_paf_structure(project_dir):
    """Ensure .paf directory structure exists."""
    paf_dir = Path(project_dir) / ".paf"
    paf_dir.mkdir(exist_ok=True)
    (paf_dir / "prompts").mkdir(exist_ok=True)
    (paf_dir / "findings").mkdir(exist_ok=True)
    (paf_dir / "status").mkdir(exist_ok=True)
    return paf_dir


def create_planner_prompt(plan_path, project_dir, framework_root):
    """Create the planner agent prompt."""
    return PLANNER_AGENT_PROMPT.format(
        plan_path=plan_path,
        project_dir=project_dir,
        framework_root=framework_root
    )


def run_planner_agent(prompt_path, output_file, timeout=1800):
    """Run the planner agent using Claude Code CLI."""
    try:
        print("🤖 Spawning planner agent...")
        print(f"   Timeout: {timeout}s ({timeout//60} minutes)")
        print(f"   Output: {output_file}")
        print()

        # Read the prompt
        with open(prompt_path, 'r') as f:
            prompt = f.read()

        # Run claude with the prompt
        cmd = [
            'claude',
            '-p', prompt
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=output_file.parent.parent  # Run in project directory
        )

        # Write output to file
        with open(output_file, 'w') as f:
            f.write(result.stdout)
            if result.stderr:
                f.write("\n\n--- STDERR ---\n")
                f.write(result.stderr)

        if result.returncode == 0:
            print("✅ Planner agent completed successfully!")
            return True
        else:
            print(f"⚠️  Planner agent exited with code {result.returncode}")
            print(f"   Check output file: {output_file}")
            return False

    except subprocess.TimeoutExpired:
        print(f"⏱️  Planner agent timed out after {timeout}s")
        return False
    except Exception as e:
        print(f"❌ Error running planner agent: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Automatically generate PAF structure from PLAN.md"
    )
    parser.add_argument(
        "plan_path",
        help="Path to PLAN.md file"
    )
    parser.add_argument(
        "--project-dir",
        default=".",
        help="Project directory (default: current directory)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Only create the prompt, don't run the agent"
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=1800,
        help="Agent timeout in seconds (default: 1800 = 30 minutes)"
    )

    args = parser.parse_args()

    # Validate inputs
    plan_path = Path(args.plan_path)
    if not plan_path.exists():
        print(f"❌ Error: PLAN.md not found at {plan_path}")
        sys.exit(1)

    project_dir = Path(args.project_dir).resolve()
    if not project_dir.exists():
        print(f"❌ Error: Project directory not found: {project_dir}")
        sys.exit(1)

    # Get framework root
    framework_root = get_framework_root()

    # Ensure .paf structure exists
    print("📂 Ensuring .paf directory structure...")
    paf_dir = ensure_paf_structure(project_dir)

    # Create planner prompt
    print("📝 Creating planner agent prompt...")
    prompt_content = create_planner_prompt(
        plan_path.resolve(),
        project_dir,
        framework_root
    )

    # Write prompt to a temp file for reference
    planner_prompt_path = paf_dir / "PLANNER_AGENT_PROMPT.md"
    planner_prompt_path.write_text(prompt_content)
    print(f"   Saved to: {planner_prompt_path}")
    print()

    if args.dry_run:
        print("\n" + "="*60)
        print("🚀 PAF Auto-Planner Ready (DRY RUN)")
        print("="*60)
        print()
        print("The planner agent prompt has been created at:")
        print(f"   {planner_prompt_path}")
        print()
        print("To execute manually, run:")
        print(f'   claude -p "$(cat {planner_prompt_path})"')
        print()
        return 0

    # Run the planner agent
    print("="*60)
    print("🚀 Starting PAF Auto-Planner Agent")
    print("="*60)
    print()
    print("The agent will analyze your PLAN.md and generate:")
    print("   - .paf/AGENT_CHARTER.md")
    print("   - .paf/DEPENDENCY_DAG.md")
    print("   - .paf/prompts/AGENT_*_PROMPT.md (one per agent)")
    print()
    print("This will create 5-15 small, focused agents organized into waves.")
    print()

    output_file = paf_dir / "PLANNER_OUTPUT.md"
    success = run_planner_agent(planner_prompt_path, output_file, args.timeout)

    print()
    print("="*60)
    if success:
        print("✅ PAF Auto-Planning Complete!")
        print()
        print("Generated files:")
        print(f"   📋 {paf_dir / 'AGENT_CHARTER.md'}")
        print(f"   🔀 {paf_dir / 'DEPENDENCY_DAG.md'}")
        print(f"   📝 {paf_dir / 'prompts'}/AGENT_*_PROMPT.md")
        print()
        print("Next steps:")
        print("   1. Review the generated charter and DAG")
        print("   2. Adjust if needed")
        print("   3. Run: paf-spawn \"Wave 1\" <agent-ids>")
    else:
        print("⚠️  PAF Auto-Planning completed with warnings")
        print()
        print(f"Check output: {output_file}")
    print("="*60)

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
