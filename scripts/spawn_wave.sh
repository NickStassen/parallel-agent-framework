#!/bin/bash
#
# Spawn a wave of agents in parallel
# Usage: ./spawn_wave.sh <wave_name> <agent1> <agent2> ... [--live]
#
# Example: ./spawn_wave.sh "Wave 1" A1 A2 A3
# Example: ./spawn_wave.sh "Wave 1" A1 A2 A3 --live
#

set -e

# Parse arguments
WAVE_NAME="$1"
shift
AGENTS=()
LIVE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --live)
            LIVE_MODE=true
            shift
            ;;
        *)
            AGENTS+=("$1")
            shift
            ;;
    esac
done

PAF_DIR="${PAF_DIR:-.paf}"
PROMPTS="$PAF_DIR/prompts"
FINDINGS="$PAF_DIR/findings"
STATUS="$PAF_DIR/status"

# Validate inputs
if [ -z "$WAVE_NAME" ] || [ ${#AGENTS[@]} -eq 0 ]; then
    echo "Usage: $0 <wave_name> <agent1> <agent2> ... [--live]"
    echo "Example: $0 \"Wave 1\" A1 A2 A3"
    echo "Example: $0 \"Wave 1\" A1 A2 A3 --live  (stream output)"
    exit 1
fi

# Validate directories exist
if [ ! -d "$PROMPTS" ]; then
    echo "Error: $PROMPTS directory not found"
    echo "Run ./init_paf.sh first"
    exit 1
fi

mkdir -p "$FINDINGS" "$STATUS"

echo "========================================="
echo "🚀 Starting $WAVE_NAME"
echo "========================================="
echo "Agents: ${AGENTS[*]}"
if [ "$LIVE_MODE" = true ]; then
    echo "Mode: Live (streaming output)"
else
    echo "Mode: Silent (output to files)"
fi
echo ""

PIDS=()
FAILED_AGENTS=()

# Helper function to prefix output lines with agent ID
prefix_output() {
    local agent=$1
    local color=$2
    while IFS= read -r line; do
        echo -e "${color}[$agent]${NC} $line"
    done
}

# ANSI color codes for better readability
if [ "$LIVE_MODE" = true ]; then
    # Colors for different agents (cycle through them)
    COLORS=(
        '\033[0;36m'  # Cyan
        '\033[0;33m'  # Yellow
        '\033[0;35m'  # Magenta
        '\033[0;32m'  # Green
        '\033[0;34m'  # Blue
        '\033[0;91m'  # Light Red
        '\033[0;92m'  # Light Green
        '\033[0;93m'  # Light Yellow
    )
    NC='\033[0m'  # No Color

    echo "📡 Live output mode - each agent's output is prefixed with [AgentID]"
    echo "   Output is also saved to .paf/findings/"
    echo ""
    echo "========================================="
    echo ""
fi

# Spawn all agents in parallel
for i in "${!AGENTS[@]}"; do
    agent="${AGENTS[$i]}"
    PROMPT_FILE="$PROMPTS/AGENT_${agent}_PROMPT.md"
    FINDINGS_FILE="$FINDINGS/${agent}_FINDINGS.md"
    STATUS_FILE="$STATUS/${agent}_STATUS.md"

    if [ ! -f "$PROMPT_FILE" ]; then
        echo "⚠️  Warning: $PROMPT_FILE not found, skipping $agent"
        continue
    fi

    echo "📝 Spawning Agent $agent..."

    # Default timeout: 600 seconds (10 minutes)
    TIMEOUT="${AGENT_TIMEOUT:-600}"

    if [ "$LIVE_MODE" = true ]; then
        # Live mode: stream to terminal with prefix AND save to file
        color_idx=$((i % ${#COLORS[@]}))
        color="${COLORS[$color_idx]}"

        (
            timeout $TIMEOUT claude --dangerously-skip-permissions -p "$(cat "$PROMPT_FILE")" 2>&1 | \
            tee "$FINDINGS_FILE" | \
            prefix_output "$agent" "$color"
        ) &
        PIDS+=($!)
    else
        # Silent mode: output only to file
        timeout $TIMEOUT claude --dangerously-skip-permissions -p "$(cat "$PROMPT_FILE")" > "$FINDINGS_FILE" 2>&1 &
        PIDS+=($!)
    fi

    echo "   PID: ${PIDS[-1]}"
done

echo ""
echo "⏳ Waiting for all agents to complete..."
echo ""

# Wait for all agents and check exit codes
for i in "${!AGENTS[@]}"; do
    agent="${AGENTS[$i]}"
    pid="${PIDS[$i]}"
    STATUS_FILE="$STATUS/${agent}_STATUS.md"

    if [ -z "$pid" ]; then
        continue
    fi

    # Wait for this specific PID
    wait $pid
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "COMPLETE" > "$STATUS_FILE"
        echo "✅ Agent $agent completed successfully"
    elif [ $EXIT_CODE -eq 124 ]; then
        echo "TIMEOUT" > "$STATUS_FILE"
        echo "⏱️  Agent $agent timed out"
        FAILED_AGENTS+=("$agent (timeout)")
    else
        echo "FAILED:$EXIT_CODE" > "$STATUS_FILE"
        echo "❌ Agent $agent failed with exit code $EXIT_CODE"
        FAILED_AGENTS+=("$agent (exit:$EXIT_CODE)")
    fi
done

echo ""
echo "========================================="
echo "📊 $WAVE_NAME Results"
echo "========================================="

if [ ${#FAILED_AGENTS[@]} -eq 0 ]; then
    echo "✅ All agents completed successfully!"
    echo ""
    exit 0
else
    echo "⚠️  ${#FAILED_AGENTS[@]} agent(s) failed:"
    for failed in "${FAILED_AGENTS[@]}"; do
        echo "   - $failed"
    done
    echo ""
    echo "Check findings and status files for details:"
    echo "   Findings: $FINDINGS/"
    echo "   Status: $STATUS/"
    echo ""
    exit 1
fi
