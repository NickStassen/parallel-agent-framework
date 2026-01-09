#!/bin/bash
#
# Spawn a wave of agents in parallel
# Usage: ./spawn_wave.sh <wave_name> <agent1> <agent2> ...
#
# Example: ./spawn_wave.sh "Wave 1" A1 A2 A3
#

set -e

WAVE_NAME="$1"
shift
AGENTS=("$@")

PAF_DIR="${PAF_DIR:-.paf}"
PROMPTS="$PAF_DIR/prompts"
FINDINGS="$PAF_DIR/findings"
STATUS="$PAF_DIR/status"

# Validate inputs
if [ -z "$WAVE_NAME" ] || [ ${#AGENTS[@]} -eq 0 ]; then
    echo "Usage: $0 <wave_name> <agent1> <agent2> ..."
    echo "Example: $0 \"Wave 1\" A1 A2 A3"
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
echo ""

PIDS=()
FAILED_AGENTS=()

# Spawn all agents in parallel
for agent in "${AGENTS[@]}"; do
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

    timeout $TIMEOUT claude -p "$(cat "$PROMPT_FILE")" > "$FINDINGS_FILE" 2>&1 &
    PIDS+=($!)

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
