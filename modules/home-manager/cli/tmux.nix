{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    tmux-sessionizer
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "xterm-256color";
    historyLimit = 10000;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
    extraConfig = with config.colorScheme.palette; ''
      set -g renumber-windows on

      # Window navigation with hjkl
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Status bar - Powerline style
      set -g status-position bottom
      set -g status-style "bg=#${base01},fg=#${base05}"
      set -g status-left-length 50
      set -g status-right-length 100
      set -g status-left "#[fg=#${base01},bg=#${base0E},bold]  #S #[fg=#${base0E},bg=#${base01}]"
      set -g status-right "#[fg=#${base0D}]#[fg=#${base01},bg=#${base0D},bold] #(cd #{pane_current_path} && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-') #[fg=#${base01},bg=#${base0D}]"

      # Window status
      set -g window-status-format "#[fg=#${base04}] #I #W "
      set -g window-status-current-format "#[fg=#${base01},bg=#${base0F}]#[fg=#${base00},bg=#${base0F},bold] #I #W #[fg=#${base0F},bg=#${base01}]"
      set -g window-status-separator ""

      # Panes and messages
      set -g pane-active-border-style "fg=#${base0E}"
      set -g pane-border-style "fg=#${base03}"
      set -g message-style "bg=#${base0E},fg=#${base00}"
    '';
  };
}
