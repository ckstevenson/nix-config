{ config, lib, pkgs, ... }:
let
  palette = config.colorScheme.palette;
  herdrAgentState = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/herdrdev/herdr/v0.8.2/src/integration/assets/opencode/herdr-agent-state.js";
    hash = "sha256-XLFeBZpfgSog/P1ktDMD77qmPBtIdLEk4l32TcAjoV4="; #pragma: allowlist secret
  };
  herdrTuiSession = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/herdrdev/herdr/v0.8.2/src/integration/assets/opencode/herdr-tui-session.js";
    hash = "sha256-3Hm5bBzRI/8iVO/Rgwshz7TAVXqwH4uZcv3/bfioVAA="; #pragma: allowlist secret
  };
in
{
  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [theme]
    name = "terminal"

    [theme.custom]
    sidebar_bg = "${palette.base00}"
    panel_bg = "${palette.base00}"
    active_row_bg = "${palette.base01}"
    selection_bg = "${palette.base02}"
    surface0 = "${palette.base01}"
    surface1 = "${palette.base02}"
    surface_dim = "${palette.base00}"
    overlay0 = "${palette.base03}"
    overlay1 = "${palette.base04}"
    text = "${palette.base05}"
    subtext0 = "${palette.base04}"
    mauve = "${palette.base0E}"
    green = "${palette.base0B}"
    yellow = "${palette.base0A}"
    red = "${palette.base08}"
    blue = "${palette.base0D}"
    teal = "${palette.base0C}"
    peach = "${palette.base09}"

    [ui]
    accent = "${palette.base0E}"

    [ui.sidebar.spaces]
    rows = [["state_icon", "$repo"], ["branch", "git_status"]]

    status_indicators = "symbols"

    [ui.toast]
    delivery = "herdr"
    delay_seconds = 1

    [ui.toast.herdr]
    position = "bottom-right"
  '';

  home.file.".config/opencode/plugins/herdr-agent-state.js".source = herdrAgentState;
  home.file.".config/opencode/herdr-tui-session.js".source = herdrTuiSession;

  programs.opencode.settings.plugin = lib.mkAfter [ "./herdr-agent-state.js" ];
  programs.opencode.tui.plugin = lib.mkAfter [ "./herdr-tui-session.js" ];
}
