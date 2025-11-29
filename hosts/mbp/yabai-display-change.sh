#!/usr/bin/env bash
# Script to handle display changes (docking/undocking)

EVENT="$1"
LOG_FILE="/tmp/yabai-display-change.log"

echo "$(date): Display event: $EVENT" >> "$LOG_FILE"

# Get display count
DISPLAY_COUNT=$(yabai -m query --displays | jq 'length')

case "$EVENT" in
  "added")
    echo "$(date): Display added. Total displays: $DISPLAY_COUNT" >> "$LOG_FILE"

    # Wait a moment for the display to stabilize
    sleep 3

    # Rebalance only existing spaces
    BALANCED=0
    for space in {1..10}; do
      if yabai -m query --spaces | jq -e ".[] | select(.index == $space)" &>/dev/null; then
        yabai -m space "$space" --balance 2>/dev/null && ((BALANCED++))
      fi
    done

    echo "$(date): Rebalanced $BALANCED spaces after docking" >> "$LOG_FILE"
    ;;

  "removed")
    echo "$(date): Display removed. Total displays: $DISPLAY_COUNT" >> "$LOG_FILE"

    # Wait a moment for the display removal to stabilize
    sleep 3

    # Rebalance only existing spaces on remaining display(s)
    BALANCED=0
    for space in {1..10}; do
      if yabai -m query --spaces | jq -e ".[] | select(.index == $space)" &>/dev/null; then
        yabai -m space "$space" --balance 2>/dev/null && ((BALANCED++))
      fi
    done

    echo "$(date): Rebalanced $BALANCED spaces after undocking" >> "$LOG_FILE"
    ;;

  *)
    echo "$(date): Unknown event: $EVENT" >> "$LOG_FILE"
    ;;
esac
