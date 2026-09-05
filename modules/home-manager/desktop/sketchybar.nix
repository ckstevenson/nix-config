{ config, lib, pkgs, ... }:
let
  cfg = config.services.sketchybar;

  # Map colorScheme palette to sketchybar colors (with 0xff prefix for opacity)
  colors = with config.colorScheme.palette; {
    bg = "0xff${base00}";
    bg_light = "0xff${base01}";
    fg = "0xff${base05}";
    fg_dim = "0xff${base03}";
    accent = "0xff${base09}";
    green = "0xff${base0B}";
    yellow = "0xff${base0A}";
    red = "0xff${base08}";
    magenta = "0xff${base0E}";
    cyan = "0xff${base0C}";
    transparent = "0x00000000";
  };

  # Plugin: Spaces/Workspaces
  spacePlugin = pkgs.writeShellScript "space.sh" ''
    #!/usr/bin/env bash
    SPACE_ID="$1"

    # Query yabai for space info
    SPACE_INFO=$(${pkgs.yabai}/bin/yabai -m query --spaces --space "$SPACE_ID" 2>/dev/null)
    if [ -z "$SPACE_INFO" ]; then
      sketchybar --set "$NAME" drawing=off
      exit 0
    fi

    # Space exists, ensure it's visible
    sketchybar --set "$NAME" drawing=on

    HAS_WINDOWS=$(echo "$SPACE_INFO" | ${pkgs.jq}/bin/jq '.windows | length > 0')
    IS_FOCUSED=$(echo "$SPACE_INFO" | ${pkgs.jq}/bin/jq '."has-focus"')

    if [ "$IS_FOCUSED" = "true" ]; then
      sketchybar --set "$NAME" \
        background.color=${colors.magenta} \
        label.color=${colors.bg}
    elif [ "$HAS_WINDOWS" = "true" ]; then
      sketchybar --set "$NAME" \
        background.color=${colors.bg_light} \
        label.color=${colors.fg}
    else
      sketchybar --set "$NAME" \
        background.color=${colors.transparent} \
        label.color=${colors.fg_dim}
    fi
  '';

  # Plugin: Current space indicator (updates on space change)
  spaceChangePlugin = pkgs.writeShellScript "space_change.sh" ''
    #!/usr/bin/env bash
    # Update all space indicators when focus changes
    # Query yabai for actual number of spaces
    SPACE_COUNT=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq 'length')
    for i in $(seq 1 $SPACE_COUNT); do
      sketchybar --trigger space_update SPACE_ID="$i"
    done
  '';

  # Plugin: Front app (focused window)
  frontAppPlugin = pkgs.writeShellScript "front_app.sh" ''
    #!/usr/bin/env bash
    if [ "$SENDER" = "front_app_switched" ]; then
      sketchybar --set "$NAME" label="$INFO"
    fi
  '';

  # Plugin: Stack/Tab indicator - shows all windows in current stack
  stackPlugin = pkgs.writeShellScript "stack.sh" ''
    #!/usr/bin/env bash

    # Get focused window info
    FOCUSED=$(${pkgs.yabai}/bin/yabai -m query --windows --window 2>/dev/null)
    if [ -z "$FOCUSED" ]; then
      sketchybar --set "$NAME" drawing=off
      exit 0
    fi

    # Get stack-index of focused window
    STACK_INDEX=$(echo "$FOCUSED" | ${pkgs.jq}/bin/jq -r '."stack-index"')

    # If stack-index is 0, window is not in a stack
    if [ "$STACK_INDEX" = "0" ] || [ "$STACK_INDEX" = "null" ]; then
      sketchybar --set "$NAME" drawing=off
      exit 0
    fi

    # Get the focused window's space
    SPACE_ID=$(echo "$FOCUSED" | ${pkgs.jq}/bin/jq -r '.space')
    FOCUSED_ID=$(echo "$FOCUSED" | ${pkgs.jq}/bin/jq -r '.id')

    # Query all windows in the same space that are stacked (stack-index > 0)
    # and have the same frame position (indicating they're in the same stack)
    FOCUSED_X=$(echo "$FOCUSED" | ${pkgs.jq}/bin/jq -r '.frame.x')
    FOCUSED_Y=$(echo "$FOCUSED" | ${pkgs.jq}/bin/jq -r '.frame.y')

    # Get all stacked windows at the same position
    STACK_WINDOWS=$(${pkgs.yabai}/bin/yabai -m query --windows --space "$SPACE_ID" | \
      ${pkgs.jq}/bin/jq -r --argjson fx "$FOCUSED_X" --argjson fy "$FOCUSED_Y" \
      '[.[] | select(."stack-index" > 0 and .frame.x == $fx and .frame.y == $fy)] | sort_by(."stack-index")')

    STACK_COUNT=$(echo "$STACK_WINDOWS" | ${pkgs.jq}/bin/jq 'length')

    if [ "$STACK_COUNT" -le 1 ]; then
      sketchybar --set "$NAME" drawing=off
      exit 0
    fi

    # Build tab display: show app names with indicator for focused
    TAB_LABEL=""
    for i in $(seq 0 $((STACK_COUNT - 1))); do
      WIN_ID=$(echo "$STACK_WINDOWS" | ${pkgs.jq}/bin/jq -r ".[$i].id")
      WIN_APP=$(echo "$STACK_WINDOWS" | ${pkgs.jq}/bin/jq -r ".[$i].app" | cut -c1-12)

      if [ "$WIN_ID" = "$FOCUSED_ID" ]; then
        TAB_LABEL="$TAB_LABEL[''${WIN_APP}] "
      else
        TAB_LABEL="$TAB_LABEL ''${WIN_APP}  "
      fi
    done

    sketchybar --set "$NAME" drawing=on label="$TAB_LABEL"
  '';

  # Plugin: Clock
  clockPlugin = pkgs.writeShellScript "clock.sh" ''
    #!/usr/bin/env bash
    sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
  '';

  # Plugin: Battery
  batteryPlugin = pkgs.writeShellScript "battery.sh" ''
    #!/usr/bin/env bash
    PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | head -1 | tr -d '%')
    CHARGING=$(pmset -g batt | grep -c "AC Power")

    if [ "$CHARGING" -gt 0 ]; then
      ICON="󰂄"
      COLOR="${colors.green}"
    elif [ "$PERCENTAGE" -gt 80 ]; then
      ICON="󰁹"
      COLOR="${colors.green}"
    elif [ "$PERCENTAGE" -gt 60 ]; then
      ICON="󰂁"
      COLOR="${colors.fg}"
    elif [ "$PERCENTAGE" -gt 40 ]; then
      ICON="󰁿"
      COLOR="${colors.fg}"
    elif [ "$PERCENTAGE" -gt 20 ]; then
      ICON="󰁽"
      COLOR="${colors.yellow}"
    else
      ICON="󰁺"
      COLOR="${colors.red}"
    fi

    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="''${PERCENTAGE}%"
  '';

  # Plugin: CPU usage
  cpuPlugin = pkgs.writeShellScript "cpu.sh" ''
    #!/usr/bin/env bash
    CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
    sketchybar --set "$NAME" label="''${CPU}%"
  '';

  # Plugin: Wifi
  wifiPlugin = pkgs.writeShellScript "wifi.sh" ''
    #!/usr/bin/env bash
    # Get Wi-Fi interface (usually en0 on Mac)
    WIFI_IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
    WIFI_IF=''${WIFI_IF:-en0}

    # Check if interface is active and has an IP
    IF_STATUS=$(ifconfig "$WIFI_IF" 2>/dev/null | awk '/status:/{print $2}')
    IP_ADDR=$(ipconfig getifaddr "$WIFI_IF" 2>/dev/null)

    if [ "$IF_STATUS" = "active" ] && [ -n "$IP_ADDR" ]; then
      sketchybar --set "$NAME" icon="󰖩" label="Connected"
    else
      sketchybar --set "$NAME" icon="󰖪" label="Disconnected"
    fi
  '';

  # Plugin: Volume
  volumePlugin = pkgs.writeShellScript "volume.sh" ''
    #!/usr/bin/env bash
    VOLUME=$(osascript -e "output volume of (get volume settings)")
    MUTED=$(osascript -e "output muted of (get volume settings)")

    if [ "$MUTED" = "true" ]; then
      ICON="󰝟"
      COLOR="${colors.fg_dim}"
    elif [ "$VOLUME" -gt 66 ]; then
      ICON="󰕾"
      COLOR="${colors.fg}"
    elif [ "$VOLUME" -gt 33 ]; then
      ICON="󰖀"
      COLOR="${colors.fg}"
    elif [ "$VOLUME" -gt 0 ]; then
      ICON="󰕿"
      COLOR="${colors.fg}"
    else
      ICON="󰝟"
      COLOR="${colors.fg_dim}"
    fi

    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="''${VOLUME}%"
  '';

  # Main sketchybar config
  sketchybarConfig = pkgs.writeShellScript "sketchybarrc" ''
    #!/usr/bin/env bash

    # Wait for yabai to be ready (max 30 seconds)
    for i in $(seq 1 30); do
      if ${pkgs.yabai}/bin/yabai -m query --spaces &>/dev/null; then
        break
      fi
      sleep 1
    done

    # Bar appearance
    sketchybar --bar \
      height=32 \
      position=bottom \
      sticky=on \
      topmost=window \
      padding_left=10 \
      padding_right=10 \
      color=${colors.bg} \
      display=all

    # Default item settings
    sketchybar --default \
      icon.font="DejaVuSansM Nerd Font Mono:Regular:16.0" \
      icon.color=${colors.fg} \
      icon.padding_right=6 \
      label.font="DejaVuSansM Nerd Font Mono:Regular:13.0" \
      label.color=${colors.fg} \
      padding_left=5 \
      padding_right=5 \
      background.height=26 \
      background.corner_radius=6

    # ===== LEFT SIDE: Workspaces =====
    # Dynamically query yabai for the number of spaces
    SPACE_COUNT=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq 'length')

    for SID in $(seq 1 $SPACE_COUNT); do
      sketchybar --add space space.$SID left \
        --set space.$SID \
          associated_space=$SID \
          icon.drawing=off \
          label="$SID" \
          label.padding_left=8 \
          label.padding_right=8 \
          background.color=${colors.transparent} \
          background.corner_radius=6 \
          background.drawing=on \
          click_script="yabai -m space --focus $SID" \
          script="${spacePlugin} $SID" \
        --subscribe space.$SID space_change mouse.clicked
    done

    # ===== CENTER: Front App =====
    sketchybar --add item front_app center \
      --set front_app \
        icon.drawing=off \
        label.font="DejaVuSansM Nerd Font Mono:Bold:13.0" \
        script="${frontAppPlugin}" \
      --subscribe front_app front_app_switched

    # ===== CENTER: Stack/Tab indicator =====
    sketchybar --add item stack_tabs center \
      --set stack_tabs \
        icon="󰓩" \
        icon.color=${colors.magenta} \
        icon.padding_right=8 \
        label.font="DejaVuSansM Nerd Font Mono:Regular:12.0" \
        label.color=${colors.fg} \
        background.color=${colors.bg_light} \
        background.corner_radius=6 \
        background.padding_left=8 \
        background.padding_right=8 \
        drawing=off \
        script="${stackPlugin}" \
      --subscribe stack_tabs stack_change front_app_switched space_change

    # ===== RIGHT SIDE: System info =====

    # Clock
    sketchybar --add item clock right \
      --set clock \
        icon="󰥔" \
        icon.color=${colors.accent} \
        update_freq=30 \
        script="${clockPlugin}"

    # Battery
    sketchybar --add item battery right \
      --set battery \
        update_freq=120 \
        script="${batteryPlugin}"

    # Volume
    sketchybar --add item volume right \
      --set volume \
        update_freq=5 \
        script="${volumePlugin}"

    # Wifi
    sketchybar --add item wifi right \
      --set wifi \
        icon.color=${colors.cyan} \
        update_freq=30 \
        script="${wifiPlugin}"

    # Force update all items
    sketchybar --update
  '';

in
{
  options.services.sketchybar = {
    enable = lib.mkEnableOption "sketchybar status bar";
  };

  config = lib.mkIf cfg.enable {
    # Ensure sketchybar is installed
    home.packages = [ pkgs.sketchybar ];

    # Configure launchd to run sketchybar
    launchd.agents.sketchybar = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" "--config" "${sketchybarConfig}" ];
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          PATH = "${pkgs.sketchybar}/bin:${pkgs.yabai}/bin:${pkgs.jq}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
        StandardOutPath = "/tmp/sketchybar.out.log";
        StandardErrorPath = "/tmp/sketchybar.err.log";
      };
    };
  };
}
