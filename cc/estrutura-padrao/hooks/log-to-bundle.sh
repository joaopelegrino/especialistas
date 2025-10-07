#!/bin/bash

# Context Bundle Logging Hook
# Automatically logs tool calls to append-only bundle for state preservation

# Configuration
BUNDLE_DIR=".agents/context-bundles"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%Y%m%d_%H%M%S)}"
BUNDLE_FILE="$BUNDLE_DIR/${SESSION_ID}_bundle.md"

# Create bundle directory if not exists
mkdir -p "$BUNDLE_DIR"

# Initialize bundle if new session
if [ ! -f "$BUNDLE_FILE" ]; then
  cat > "$BUNDLE_FILE" << EOF
# Context Bundle: $SESSION_ID

**Created**: $(date '+%Y-%m-%d %H:%M:%S')
**Session ID**: $SESSION_ID

---

## Initial Context

**Working Directory**: $(pwd)
**Git Branch**: $(git branch --show-current 2>/dev/null || echo "N/A")

---

## Tool Call Log

EOF
fi

# Parse tool information from environment
# Note: Actual implementation depends on Claude Code hook interface
# This is a template showing the structure

TOOL_NAME="${TOOL_NAME:-unknown}"
TIMESTAMP=$(date '+%H:%M:%S')

# Log based on tool type
case "$TOOL_NAME" in
  "Read")
    FILE_PATH="${FILE_PATH:-}"
    OFFSET="${OFFSET:-0}"
    LIMIT="${LIMIT:-100}"
    if [ -n "$FILE_PATH" ]; then
      END=$((OFFSET + LIMIT))
      echo "[$TIMESTAMP] **Read**: \`$FILE_PATH\` (lines $OFFSET-$END)" >> "$BUNDLE_FILE"
    fi
    ;;

  "Write")
    FILE_PATH="${FILE_PATH:-}"
    if [ -n "$FILE_PATH" ]; then
      echo "[$TIMESTAMP] **Write**: \`$FILE_PATH\`" >> "$BUNDLE_FILE"
    fi
    ;;

  "Edit")
    FILE_PATH="${FILE_PATH:-}"
    if [ -n "$FILE_PATH" ]; then
      echo "[$TIMESTAMP] **Edit**: \`$FILE_PATH\`" >> "$BUNDLE_FILE"
    fi
    ;;

  "Grep")
    PATTERN="${PATTERN:-}"
    MATCHES="${MATCH_COUNT:-0}"
    if [ -n "$PATTERN" ]; then
      echo "[$TIMESTAMP] **Grep**: \`$PATTERN\` → $MATCHES matches" >> "$BUNDLE_FILE"
    fi
    ;;

  "Glob")
    PATTERN="${PATTERN:-}"
    if [ -n "$PATTERN" ]; then
      echo "[$TIMESTAMP] **Glob**: \`$PATTERN\`" >> "$BUNDLE_FILE"
    fi
    ;;

  "Bash")
    COMMAND="${COMMAND:-}"
    if [ -n "$COMMAND" ]; then
      # Truncate long commands
      SHORT_CMD=$(echo "$COMMAND" | head -c 60)
      if [ ${#COMMAND} -gt 60 ]; then
        SHORT_CMD="${SHORT_CMD}..."
      fi
      echo "[$TIMESTAMP] **Bash**: \`$SHORT_CMD\`" >> "$BUNDLE_FILE"
    fi
    ;;

  "Task")
    DESCRIPTION="${DESCRIPTION:-}"
    AGENT_TYPE="${AGENT_TYPE:-}"
    if [ -n "$DESCRIPTION" ]; then
      echo "[$TIMESTAMP] **Task**: $DESCRIPTION (agent: $AGENT_TYPE)" >> "$BUNDLE_FILE"
    fi
    ;;

  "WebFetch")
    URL="${URL:-}"
    if [ -n "$URL" ]; then
      echo "[$TIMESTAMP] **WebFetch**: $URL" >> "$BUNDLE_FILE"
    fi
    ;;

  *)
    # Generic logging for unknown tools
    if [ -n "$TOOL_NAME" ] && [ "$TOOL_NAME" != "unknown" ]; then
      echo "[$TIMESTAMP] **$TOOL_NAME**: [tool used]" >> "$BUNDLE_FILE"
    fi
    ;;
esac

# Add separator every 10 tool calls
CALL_COUNT=$(grep -c "^\[" "$BUNDLE_FILE")
if [ $((CALL_COUNT % 10)) -eq 0 ] && [ $CALL_COUNT -gt 0 ]; then
  echo "" >> "$BUNDLE_FILE"
  echo "---" >> "$BUNDLE_FILE"
  echo "" >> "$BUNDLE_FILE"
fi

# Optional: Add section headers at key milestones
if grep -q "^## Tool Call Log$" "$BUNDLE_FILE" && ! grep -q "^## Key Findings$" "$BUNDLE_FILE"; then
  # After significant work, could add a findings section
  # This would be triggered by specific conditions or manually
  :
fi

# Exit successfully
exit 0
