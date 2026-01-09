#!/bin/bash
#
# Automatically execute all waves from AGENT_CHARTER.md
# Usage: ./auto_execute_waves.sh [--live]
#
# Reads the agent charter, parses waves, and executes them in order
#

set -e

PAF_DIR="${PAF_DIR:-.paf}"
CHARTER="$PAF_DIR/AGENT_CHARTER.md"
LIVE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --live)
            LIVE_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--live]"
            exit 1
            ;;
    esac
done

# Check if charter exists
if [ ! -f "$CHARTER" ]; then
    echo "❌ Error: AGENT_CHARTER.md not found at $CHARTER"
    echo ""
    echo "Run 'paf-init' and create your charter first, or use 'paf-plan' to auto-generate."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 PAF Auto-Executor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Reading agent charter: $CHARTER"
echo ""

# Function to extract agents from a wave section
extract_wave_agents() {
    local wave_num=$1
    local agents=()

    # Find the wave section and extract agent IDs from the table
    # Look for lines like: | **A1** | Role | Task | ...
    in_wave=false
    wave_pattern="Wave $wave_num"

    while IFS= read -r line; do
        # Check if we're entering the target wave section
        if [[ "$line" =~ ^###[[:space:]]*Wave[[:space:]]+$wave_num ]]; then
            in_wave=true
            continue
        fi

        # Check if we've hit the next wave section (stop parsing)
        if [[ "$in_wave" == true ]] && [[ "$line" =~ ^###[[:space:]]*Wave[[:space:]]+[0-9]+ ]]; then
            break
        fi

        # Extract agent IDs from table rows
        if [[ "$in_wave" == true ]] && [[ "$line" =~ ^\|[[:space:]]*\*\*([A-Z0-9]+)\*\* ]]; then
            agent="${BASH_REMATCH[1]}"
            agents+=("$agent")
        fi
    done < "$CHARTER"

    echo "${agents[@]}"
}

# Function to extract wave name
extract_wave_name() {
    local wave_num=$1
    local wave_name=""

    # Look for pattern: ### Wave N: [Name]
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]]*Wave[[:space:]]+$wave_num[[:space:]]*:[[:space:]]*(.+)$ ]]; then
            wave_name="${BASH_REMATCH[1]}"
            # Remove trailing " (Spawn" patterns
            wave_name="${wave_name%% \(Spawn*}"
            break
        elif [[ "$line" =~ ^###[[:space:]]*Wave[[:space:]]+$wave_num[[:space:]]*-[[:space:]]*(.+)$ ]]; then
            wave_name="${BASH_REMATCH[1]}"
            wave_name="${wave_name%% \(Spawn*}"
            break
        fi
    done < "$CHARTER"

    # Default if not found
    if [ -z "$wave_name" ]; then
        wave_name="Wave $wave_num"
    fi

    echo "$wave_name"
}

# Count total waves in charter
count_waves() {
    grep -c "^### Wave [0-9]" "$CHARTER" || echo "0"
}

# Main execution
TOTAL_WAVES=$(count_waves)

if [ "$TOTAL_WAVES" -eq 0 ]; then
    echo "❌ No waves found in AGENT_CHARTER.md"
    echo ""
    echo "Your charter should have sections like:"
    echo "  ### Wave 1: [Wave Name]"
    echo "  ### Wave 2: [Wave Name]"
    exit 1
fi

echo "Found $TOTAL_WAVES wave(s) to execute"
echo ""

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Track overall success
OVERALL_SUCCESS=true

# Execute each wave in order
for wave_num in $(seq 1 $TOTAL_WAVES); do
    wave_name=$(extract_wave_name $wave_num)
    agents=($(extract_wave_agents $wave_num))

    if [ ${#agents[@]} -eq 0 ]; then
        echo "⚠️  Warning: Wave $wave_num has no agents, skipping"
        echo ""
        continue
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Wave $wave_num: $wave_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Agents: ${agents[*]}"
    echo ""

    # Build spawn command
    if [ "$LIVE_MODE" = true ]; then
        spawn_cmd=("$SCRIPT_DIR/spawn_wave.sh" "$wave_name" "${agents[@]}" "--live")
    else
        spawn_cmd=("$SCRIPT_DIR/spawn_wave.sh" "$wave_name" "${agents[@]}")
    fi

    # Execute wave
    if "${spawn_cmd[@]}"; then
        echo ""
        echo "✅ Wave $wave_num completed successfully"
        echo ""
    else
        echo ""
        echo "❌ Wave $wave_num failed"
        echo ""
        OVERALL_SUCCESS=false

        # Ask user if they want to continue
        read -p "Continue to next wave? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Execution stopped by user"
            exit 1
        fi
        echo ""
    fi

    # Small delay between waves
    if [ $wave_num -lt $TOTAL_WAVES ]; then
        sleep 2
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Execution Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$OVERALL_SUCCESS" = true ]; then
    echo "✅ All $TOTAL_WAVES wave(s) completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. paf-validate    - Validate findings format"
    echo "  2. Review findings in .paf/findings/"
    echo "  3. Synthesize into final implementation plan"
else
    echo "⚠️  Some waves had failures"
    echo ""
    echo "Check status and findings:"
    echo "  paf-status    - Check completion status"
    echo "  paf-validate  - Validate findings format"
fi

echo ""
