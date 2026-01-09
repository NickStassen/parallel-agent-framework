#!/bin/bash
#
# Install Parallel Agent Framework (PAF) commands to PATH
# Usage: ./install.sh [--global]
#
# Default: Installs to ~/.local/bin (user-only)
# --global: Installs to /usr/local/bin (system-wide, requires sudo)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_INSTALL=false

# Parse arguments
if [ "$1" == "--global" ]; then
    GLOBAL_INSTALL=true
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Parallel Agent Framework (PAF) Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📁 Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "⚠️  Warning: $INSTALL_DIR is not in your PATH"
    echo ""
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Create PAF config directory
PAF_CONFIG_DIR="$HOME/.config/paf"
mkdir -p "$PAF_CONFIG_DIR"

# Store framework location
echo "$SCRIPT_DIR" > "$PAF_CONFIG_DIR/framework_path"

echo "📝 Framework location: $SCRIPT_DIR"
echo "📦 Install directory: $INSTALL_DIR"
echo ""

# Install wrapper scripts
echo "🔧 Installing PAF commands..."

# 1. paf-init - Initialize PAF in current directory
cat > "$INSTALL_DIR/paf-init" << 'EOFSCRIPT'
#!/bin/bash
# Initialize Parallel Agent Framework in current directory

set -e

PAF_CONFIG_DIR="$HOME/.config/paf"
FRAMEWORK_PATH=$(cat "$PAF_CONFIG_DIR/framework_path" 2>/dev/null)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "Error: PAF not installed. Run install.sh first."
    exit 1
fi

# Run the init script from framework
"$FRAMEWORK_PATH/scripts/init_paf.sh" "$(pwd)"
EOFSCRIPT

# 2. paf-spawn - Spawn a wave of agents
cat > "$INSTALL_DIR/paf-spawn" << 'EOFSCRIPT'
#!/bin/bash
# Spawn a wave of PAF agents
# Usage: paf-spawn <wave_name> <agent1> <agent2> ...

set -e

PAF_CONFIG_DIR="$HOME/.config/paf"
FRAMEWORK_PATH=$(cat "$PAF_CONFIG_DIR/framework_path" 2>/dev/null)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "Error: PAF not installed. Run install.sh first."
    exit 1
fi

# Run the spawn script from framework
"$FRAMEWORK_PATH/scripts/spawn_wave.sh" "$@"
EOFSCRIPT

# 3. paf-status - Check status of all agents
cat > "$INSTALL_DIR/paf-status" << 'EOFSCRIPT'
#!/bin/bash
# Check status of all PAF agents in current directory

PAF_DIR="${PAF_DIR:-.paf}"
STATUS_DIR="$PAF_DIR/status"

if [ ! -d "$STATUS_DIR" ]; then
    echo "Error: No .paf/status directory found"
    echo "Run 'paf-init' first"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 PAF Agent Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL=0
COMPLETE=0
FAILED=0
TIMEOUT=0

for status_file in "$STATUS_DIR"/*.md; do
    if [ ! -f "$status_file" ]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    agent=$(basename "$status_file" .md | sed 's/_STATUS//')
    status=$(cat "$status_file" 2>/dev/null || echo "UNKNOWN")

    case "$status" in
        COMPLETE)
            echo "✅ $agent: $status"
            COMPLETE=$((COMPLETE + 1))
            ;;
        TIMEOUT)
            echo "⏱️  $agent: $status"
            TIMEOUT=$((TIMEOUT + 1))
            ;;
        FAILED*)
            echo "❌ $agent: $status"
            FAILED=$((FAILED + 1))
            ;;
        *)
            echo "❓ $agent: $status"
            ;;
    esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $COMPLETE/$TOTAL complete, $FAILED failed, $TIMEOUT timeout"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOFSCRIPT

# 4. paf-validate - Validate agent findings
cat > "$INSTALL_DIR/paf-validate" << 'EOFSCRIPT'
#!/bin/bash
# Validate PAF agent findings formats

PAF_DIR="${PAF_DIR:-.paf}"
FINDINGS_DIR="$PAF_DIR/findings"

if [ ! -d "$FINDINGS_DIR" ]; then
    echo "Error: No .paf/findings directory found"
    echo "Run 'paf-init' first"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Validating Agent Findings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REQUIRED_SECTIONS=(
    "Executive Summary"
    "Key Findings"
    "Recommendations"
    "Confidence Level"
)

TOTAL=0
VALID=0
INVALID=0

for findings_file in "$FINDINGS_DIR"/*.md; do
    if [ ! -f "$findings_file" ] || [ ! -s "$findings_file" ]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    agent=$(basename "$findings_file" .md)
    missing=()

    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -q "## $section" "$findings_file"; then
            missing+=("$section")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo "✅ $agent: Valid"
        VALID=$((VALID + 1))
    else
        echo "❌ $agent: Missing sections: ${missing[*]}"
        INVALID=$((INVALID + 1))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $VALID/$TOTAL valid, $INVALID invalid"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $INVALID -gt 0 ]; then
    exit 1
fi
EOFSCRIPT

# 5. paf-clean - Clean PAF execution artifacts
cat > "$INSTALL_DIR/paf-clean" << 'EOFSCRIPT'
#!/bin/bash
# Clean PAF execution artifacts (findings and status)

PAF_DIR="${PAF_DIR:-.paf}"

if [ ! -d "$PAF_DIR" ]; then
    echo "Error: No .paf directory found"
    exit 1
fi

echo "🧹 Cleaning PAF execution artifacts..."
echo ""

# Ask for confirmation
read -p "This will delete all findings and status files. Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Clean findings
if [ -d "$PAF_DIR/findings" ]; then
    rm -f "$PAF_DIR/findings"/*.md
    echo "✅ Cleaned findings/"
fi

# Clean status
if [ -d "$PAF_DIR/status" ]; then
    rm -f "$PAF_DIR/status"/*.md
    echo "✅ Cleaned status/"
fi

echo ""
echo "✨ Clean complete!"
EOFSCRIPT

# 6. paf-plan - Auto-generate PAF setup from PLAN.md
cat > "$INSTALL_DIR/paf-plan" << 'EOFSCRIPT'
#!/bin/bash
# Auto-generate PAF setup from PLAN.md
# Usage: paf-plan <path-to-PLAN.md> [--dry-run]

set -e

PAF_CONFIG_DIR="$HOME/.config/paf"
FRAMEWORK_PATH=$(cat "$PAF_CONFIG_DIR/framework_path" 2>/dev/null)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "Error: PAF not installed. Run install.sh first."
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required for paf-plan"
    exit 1
fi

# Run the auto planner
python3 "$FRAMEWORK_PATH/scripts/paf_auto_planner.py" "$@"
EOFSCRIPT

# 7. paf-auto - Auto-execute all waves from charter
cat > "$INSTALL_DIR/paf-auto" << 'EOFSCRIPT'
#!/bin/bash
# Automatically execute all waves from AGENT_CHARTER.md
# Usage: paf-auto [--live]

set -e

PAF_CONFIG_DIR="$HOME/.config/paf"
FRAMEWORK_PATH=$(cat "$PAF_CONFIG_DIR/framework_path" 2>/dev/null)

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "Error: PAF not installed. Run install.sh first."
    exit 1
fi

# Run the auto executor
"$FRAMEWORK_PATH/scripts/auto_execute_waves.sh" "$@"
EOFSCRIPT

# Make all scripts executable
chmod +x "$INSTALL_DIR/paf-init"
chmod +x "$INSTALL_DIR/paf-spawn"
chmod +x "$INSTALL_DIR/paf-status"
chmod +x "$INSTALL_DIR/paf-validate"
chmod +x "$INSTALL_DIR/paf-clean"
chmod +x "$INSTALL_DIR/paf-plan"
chmod +x "$INSTALL_DIR/paf-auto"

echo "✅ Installed commands:"
echo "   • paf-init      - Initialize PAF in current directory"
echo "   • paf-plan      - Auto-generate PAF setup from PLAN.md"
echo "   • paf-auto      - Auto-execute all waves from charter"
echo "   • paf-spawn     - Spawn a wave of agents (manual)"
echo "   • paf-status    - Check agent completion status"
echo "   • paf-validate  - Validate findings format"
echo "   • paf-clean     - Clean execution artifacts"
echo ""

# Create example usage file
cat > "$PAF_CONFIG_DIR/USAGE.txt" << 'EOF'
Parallel Agent Framework (PAF) - Quick Reference

INITIALIZATION:
  cd /path/to/your/project
  paf-init                    Initialize .paf directory structure

AUTO-PLANNING (NEW!):
  paf-plan PLAN.md            Auto-generate PAF setup from PLAN.md
  paf-plan PLAN.md --dry-run  Generate prompt only, don't run agent
  paf-plan PLAN.md --live     Generate with live output

EXECUTION:
  paf-auto                    Auto-execute all waves from charter
  paf-auto --live             Auto-execute with live output
  paf-spawn "Wave 1" A1 A2 A3 Manually spawn specific agents
  paf-status                  Check completion status of all agents
  paf-validate                Validate findings format

CLEANUP:
  paf-clean                   Remove findings and status files

DIRECTORY STRUCTURE:
  .paf/
  ├── AGENT_CHARTER.md        Define agent roster
  ├── DEPENDENCY_DAG.md       Map dependencies
  ├── prompts/                Agent instruction files
  ├── findings/               Agent outputs (generated)
  └── status/                 Completion signals (generated)

WORKFLOW (Manual):
  1. paf-init
  2. Edit .paf/AGENT_CHARTER.md
  3. Edit .paf/DEPENDENCY_DAG.md
  4. Create agent prompts in .paf/prompts/
  5. paf-spawn "Wave 1" A1 A2 A3
  6. paf-status
  7. paf-validate
  8. Synthesize findings into final plan

WORKFLOW (Fully Automated - FASTEST):
  1. Create PLAN.md with your task description
  2. paf-plan PLAN.md --live      (auto-generates all PAF files)
  3. paf-auto --live              (auto-executes all waves)
  4. paf-validate
  5. Review findings and synthesize

WORKFLOW (Semi-Automated):
  1. Create PLAN.md with your task description
  2. paf-plan PLAN.md             (auto-generates all PAF files)
  3. Review .paf/AGENT_CHARTER.md and .paf/DEPENDENCY_DAG.md
  4. paf-spawn "Wave 1" <agents>  (manual execution)
  5. paf-status
  6. paf-validate
  7. Synthesize findings into final plan

DOCUMENTATION:
  Framework: $FRAMEWORK_PATH/FRAMEWORK.md
  Examples:  $FRAMEWORK_PATH/EXAMPLES.md
  Practices: $FRAMEWORK_PATH/docs/BEST_PRACTICES.md
EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Quick reference saved to: $PAF_CONFIG_DIR/USAGE.txt"
echo ""
echo "🚀 Get started:"
echo "   cd your-project"
echo "   paf-init"
echo ""

# Check if PATH warning was shown
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "⚠️  Don't forget to add $INSTALL_DIR to your PATH!"
    echo ""
fi
