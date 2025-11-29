{ pkgs, ... }:
let
  yabaiDisplayChange = pkgs.writeShellScript "yabai-display-change" ''
    #!/usr/bin/env bash
    # Script to handle display changes (docking/undocking)

    EVENT="$1"
    LOG_FILE="/tmp/yabai-display-change.log"

    echo "$(date): Display event: $EVENT" >> "$LOG_FILE"

    # Get display count
    DISPLAY_COUNT=$(${pkgs.yabai}/bin/yabai -m query --displays | ${pkgs.jq}/bin/jq 'length')

    # Function to ensure correct number of spaces per display
    setup_spaces() {
      local display=$1
      local target_spaces=$2

      # Check if display exists
      if ! ${pkgs.yabai}/bin/yabai -m query --displays --display "$display" &>/dev/null; then
        return
      fi

      # Get current space count for this display
      local current_spaces=$(${pkgs.yabai}/bin/yabai -m query --spaces --display "$display" 2>/dev/null | ${pkgs.jq}/bin/jq 'length' 2>/dev/null || echo "0")

      if [ "$current_spaces" = "0" ]; then
        return
      fi

      local spaces_needed=$((target_spaces - current_spaces))

      if [ $spaces_needed -gt 0 ]; then
        echo "$(date): Creating $spaces_needed spaces on display $display" >> "$LOG_FILE"
        # Create additional spaces on this display
        for _ in $(seq 1 $spaces_needed); do
          ${pkgs.yabai}/bin/yabai -m display --focus "$display" 2>/dev/null
          ${pkgs.yabai}/bin/yabai -m space --create 2>/dev/null
        done
      fi
    }

    case "$EVENT" in
      "added")
        echo "$(date): Display added. Total displays: $DISPLAY_COUNT" >> "$LOG_FILE"

        # Wait for the display to fully stabilize
        sleep 3

        # Setup spaces for each display
        # Display 1 (main external): 5 spaces
        # Display 2 (secondary external): 4 spaces
        # Display 3 (built-in laptop): 1 space
        setup_spaces 1 5
        setup_spaces 2 4
        setup_spaces 3 1

        # Rebalance all existing spaces
        SPACE_IDS=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[].id')
        BALANCED=0
        for space_id in $SPACE_IDS; do
          if ${pkgs.yabai}/bin/yabai -m query --spaces --space "$space_id" &>/dev/null; then
            ${pkgs.yabai}/bin/yabai -m space "$space_id" --balance 2>/dev/null && BALANCED=$((BALANCED + 1))
          fi
        done

        echo "$(date): Rebalanced $BALANCED spaces after docking" >> "$LOG_FILE"
        ;;

      "removed")
        echo "$(date): Display removed. Total displays: $DISPLAY_COUNT" >> "$LOG_FILE"

        # Wait for the display removal to fully stabilize
        sleep 3

        # Rebalance all existing spaces on remaining display(s)
        SPACE_IDS=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[].id')
        BALANCED=0
        for space_id in $SPACE_IDS; do
          if ${pkgs.yabai}/bin/yabai -m query --spaces --space "$space_id" &>/dev/null; then
            ${pkgs.yabai}/bin/yabai -m space "$space_id" --balance 2>/dev/null && BALANCED=$((BALANCED + 1))
          fi
        done

        echo "$(date): Rebalanced $BALANCED spaces after undocking" >> "$LOG_FILE"
        ;;

      *)
        echo "$(date): Unknown event: $EVENT" >> "$LOG_FILE"
        ;;
    esac
  '';
in
{
  services = {
    yabai = {
      enable = true;
      config = {
        layout = "bsp";
        window_placement = "second_child";
        mouse_follows_focus = "on";
        focus_follows_mouse = "autoraise";
        top_padding = 5;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };
      extraConfig = ''
        # Configure spaces across displays when docked:
        # - Display 1 (main external): 5 spaces
        # - Display 2 (secondary external): 4 spaces
        # - Display 3 (built-in laptop): 1 space (default)

        # Function to ensure correct number of spaces per display
        setup_spaces() {
          local display=$1
          local target_spaces=$2

          # Get current space count for this display
          local current_spaces=$(yabai -m query --spaces --display "$display" 2>/dev/null | jq 'length' 2>/dev/null || echo "0")

          if [ "$current_spaces" = "0" ]; then
            # Display doesn't exist (not docked), skip
            return
          fi

          local spaces_needed=$((target_spaces - current_spaces))

          if [ $spaces_needed -gt 0 ]; then
            # Create additional spaces on this display
            for _ in $(seq 1 $spaces_needed); do
              yabai -m display --focus "$display" 2>/dev/null
              yabai -m space --create 2>/dev/null
            done
          fi
        }

        # Wait a moment for displays to initialize
        sleep 1

        # Setup spaces for each display
        setup_spaces 1 5  # Main external display: 5 spaces
        setup_spaces 2 4  # Secondary external display: 4 spaces
        setup_spaces 3 1  # Built-in laptop: 1 space (default)

        # Load scripting addition on restart
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa

        # Display change handlers for docking/undocking
        # When display is added (docking)
        yabai -m signal --add event=display_added action="${yabaiDisplayChange} added"

        # When display is removed (undocking)
        yabai -m signal --add event=display_removed action="${yabaiDisplayChange} removed"

        # Application rules
        yabai -m rule --add app="^System Settings$"    manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add title="Preferences$"       manage=off
        yabai -m rule --add title="Settings$"          manage=off
        yabai -m rule --add title="^Notes$" scratchpad=Notes grid=11:11:1:1:9:9
        yabai -m rule --add app="^1Password$"    manage=off
        yabai -m rule --add app="^Slack$"       space=9
        yabai -m rule --add app="^Microsoft Teams$"       space=9
      '';
    };
  };
}
