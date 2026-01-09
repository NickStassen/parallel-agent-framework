#!/bin/bash
#
# Initialize Parallel Agent Framework in a project
# Usage: ./init_paf.sh [project-directory]
#

set -e

# Determine project directory
PROJECT_DIR="${1:-.}"
PAF_DIR="$PROJECT_DIR/.paf"

echo "🚀 Initializing Parallel Agent Framework..."
echo "📁 Project: $PROJECT_DIR"

# Create directory structure
echo "📂 Creating .paf directory structure..."
mkdir -p "$PAF_DIR"/{prompts,findings,status}

# Get the directory where this script lives (framework repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(dirname "$SCRIPT_DIR")"

# Copy templates
echo "📋 Copying templates..."
cp "$FRAMEWORK_ROOT/templates/AGENT_CHARTER_TEMPLATE.md" "$PAF_DIR/AGENT_CHARTER.md"
cp "$FRAMEWORK_ROOT/templates/DEPENDENCY_DAG_TEMPLATE.md" "$PAF_DIR/DEPENDENCY_DAG.md"

# Copy framework document to project root
echo "📚 Copying framework documentation..."
cp "$FRAMEWORK_ROOT/FRAMEWORK.md" "$PROJECT_DIR/PARALLEL_AGENT_FRAMEWORK.md"

# Create README in .paf
cat > "$PAF_DIR/README.md" << 'EOF'
# Parallel Agent Framework Workspace

This directory contains the PAF execution workspace for this project.

## Directory Structure

```
.paf/
├── README.md                    ← You are here
├── AGENT_CHARTER.md             ← Define agent roster and missions
├── DEPENDENCY_DAG.md            ← Map dependencies and waves
│
├── prompts/                     ← Agent instruction files
│   ├── AGENT_A1_PROMPT.md
│   ├── AGENT_A2_PROMPT.md
│   └── ...
│
├── findings/                    ← Agent outputs
│   ├── A1_FINDINGS.md
│   ├── A2_FINDINGS.md
│   └── ...
│
└── status/                      ← Completion signals
    ├── A1_STATUS.md             ← COMPLETE | FAILED | TIMEOUT
    ├── A2_STATUS.md
    └── ...
```

## Next Steps

1. Edit `AGENT_CHARTER.md` - Define your agents and missions
2. Edit `DEPENDENCY_DAG.md` - Map task dependencies
3. Create agent prompts in `prompts/` directory
4. Execute waves (see ../PARALLEL_AGENT_FRAMEWORK.md)
5. Validate findings in `findings/` directory
6. Synthesize into final plan

## Quick Start

See `../PARALLEL_AGENT_FRAMEWORK.md` for complete documentation.
EOF

# Create .gitignore for .paf
cat > "$PAF_DIR/.gitignore" << 'EOF'
# Agent outputs (generated during execution)
findings/
status/

# Keep directory structure
!findings/.gitkeep
!status/.gitkeep
EOF

# Create .gitkeep files
touch "$PAF_DIR/findings/.gitkeep"
touch "$PAF_DIR/status/.gitkeep"
touch "$PAF_DIR/prompts/.gitkeep"

echo ""
echo "✅ PAF initialized successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Edit .paf/AGENT_CHARTER.md"
echo "   2. Edit .paf/DEPENDENCY_DAG.md"
echo "   3. Create agent prompts in .paf/prompts/"
echo "   4. Review PARALLEL_AGENT_FRAMEWORK.md"
echo ""
echo "📚 Documentation: $PROJECT_DIR/PARALLEL_AGENT_FRAMEWORK.md"
echo "🎯 Charter: $PAF_DIR/AGENT_CHARTER.md"
echo ""
