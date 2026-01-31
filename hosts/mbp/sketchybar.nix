{ pkgs, config, ... }:
let
  # Color scheme from home.nix oxocarbon theme
  colors = {
    bg = "0xff161616";
    bg_light = "0xff262626";
    fg = "0xfff2f4f8";
    fg_dim = "0xff525252";
    accent = "0xff78a9ff";
    green = "0xff42be65";
    yellow = "0xffffcb6b";
    red = "0xffff7eb6";
    magenta = "0xffbe95ff";
    cyan = "0xff3ddbd9";
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

    HAS_WINDOWS=$(echo "$SPACE_INFO" | ${pkgs.jq}/bin/jq '.windows | length > 0')
    IS_FOCUSED=$(echo "$SPACE_INFO" | ${pkgs.jq}/bin/jq '."has-focus"')

    if [ "$IS_FOCUSED" = "true" ]; then
      sketchybar --set "$NAME" \
        icon.color=${colors.bg} \
        background.color=${colors.accent} \
        label.color=${colors.bg}
    elif [ "$HAS_WINDOWS" = "true" ]; then
      sketchybar --set "$NAME" \
        icon.color=${colors.fg} \
        background.color=${colors.bg_light} \
        label.color=${colors.fg}
    else
      sketchybar --set "$NAME" \
        icon.color=${colors.fg_dim} \
        background.color=${colors.transparent} \
        label.color=${colors.fg_dim}
    fi
  '';

  # Plugin: Current space indicator (updates on space change)
  spaceChangePlugin = pkgs.writeShellScript "space_change.sh" ''
    #!/usr/bin/env bash
    # Update all space indicators when focus changes
    for i in $(seq 1 10); do
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
    SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/{print $2}')
    if [ -z "$SSID" ]; then
      sketchybar --set "$NAME" icon="󰖪" label="Disconnected"
    else
      sketchybar --set "$NAME" icon="󰖩" label="$SSID"
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

    # Load helper location
    PLUGIN_DIR="${pkgs.writeTextDir "plugins" ""}/plugins"

    # Bar appearance
    sketchybar --bar \
      height=32 \
      blur_radius=30 \
      position=bottom \
      sticky=on \
      padding_left=10 \
      padding_right=10 \
      color=${colors.bg} \
      shadow=on

    # Default item settings
    sketchybar --default \
      icon.font="DejaVuSansM Nerd Font Mono:Regular:14.0" \
      icon.color=${colors.fg} \
      label.font="DejaVuSansM Nerd Font Mono:Regular:13.0" \
      label.color=${colors.fg} \
      padding_left=5 \
      padding_right=5 \
      background.height=26 \
      background.corner_radius=6

    # ===== LEFT SIDE: Workspaces =====
    SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

    for i in "''${!SPACE_ICONS[@]}"; do
      SID=$((i + 1))
      sketchybar --add space space.$SID left \
        --set space.$SID \
          associated_space=$SID \
          icon="''${SPACE_ICONS[i]}" \
          icon.padding_left=8 \
          icon.padding_right=8 \
          background.color=${colors.transparent} \
          background.corner_radius=6 \
          background.drawing=on \
          click_script="yabai -m space --focus $SID" \
          script="${spacePlugin} $SID" \
        --subscribe space.$SID space_change mouse.clicked
    done

    # Separator after spaces
    sketchybar --add item separator left \
      --set separator \
        icon="│" \
        icon.color=${colors.fg_dim} \
        label.drawing=off \
        padding_left=10 \
        padding_right=5

    # ===== CENTER: Front App =====
    sketchybar --add item front_app center \
      --set front_app \
        icon.drawing=off \
        label.font="DejaVuSansM Nerd Font Mono:Bold:13.0" \
        script="${frontAppPlugin}" \
      --subscribe front_app front_app_switched

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
  # Create the sketchybar config directory and files
  # The launchd service handles running sketchybar

  launchd.user.agents.sketchybar = {
    serviceConfig = {
      ProgramArguments = [ "/opt/homebrew/bin/sketchybar" "--config" "${sketchybarConfig}" ];
      KeepAlive = true;
      RunAtLoad = true;
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${pkgs.yabai}/bin:${pkgs.jq}/bin";
      };
      StandardOutPath = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
    };
  };
}
