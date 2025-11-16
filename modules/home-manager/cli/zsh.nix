{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      extended = true;
      ignoreSpace = true;
    };

    initContent = ''
      bindkey '^ ' autosuggest-execute
      bindkey '^R' history-incremental-pattern-search-backward

      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      #bindkey -v
      # ability to delete chars in vi mode
      #bindkey "^?" backward-delete-char

      # prompt
      autoload -Uz vcs_info
      precmd_vcs_info() { vcs_info }
      precmd_functions+=( precmd_vcs_info )
      zstyle ':vcs_info:git:*' formats ' %F{red}%r on %F{cyan}%b'
      setopt prompt_subst
      PROMPT='%F{blue}%m %F{magenta}%2~'\$vcs_info_msg_0_' %F{yellow}>%f '
    '';
    completionInit = ''
      if [[ -n $(print ~/.zcompdump(Nmh+24)) ]] {
        # Regenerate completions because the dump file hasn't been modified within the last 24 hours
        compinit
      } else {
        # Reuse the existing completions file
        compinit -C
      }
    '';
    #  autoload -U colors && colors

    #bindkey "^A" vi-beginning-of-line
    #bindkey "^E" vi-end-of-line

    # # zmodload zsh/complist
    # # compinit
    # # _comp_options+=(globdots)		# Include hidden files.
    # # # use the vi navigation keys in menu completion
    # # bindkey -M menuselect 'h' vi-backward-char
    # # bindkey -M menuselect 'k' vi-up-line-or-history
    # # bindkey -M menuselect 'l' vi-forward-char
    # # bindkey -M menuselect 'j' vi-down-line-or-history

    #  # prompt
    #  autoload -Uz vcs_info
    #  precmd_vcs_info() { vcs_info }
    #  precmd_functions+=( precmd_vcs_info )
    #  zstyle ':vcs_info:git:*' formats ' %F{red}%r on %F{cyan}%b'
    #  setopt prompt_subst
    #  PROMPT='%F{blue}%m %F{magenta}%2~'\$vcs_info_msg_0_' %F{yellow}>%f '

    #  # Enable searching through history

    # # # ci", ci', ci`, di", etc
    # # autoload -U select-quoted
    # # zle -N select-quoted
    # # for m in visual viopp; do
    # #   for c in {a,i}{\',\",\`}; do
    # #     bindkey -M $m $c select-quoted
    # #   done
    # # done

    # # # Control bindings for programs
    # # bindkey -s "^b" "bc -l\n"
    # # bindkey -s "^f" "$FILE\n"
    # # #bindkey -s "^m" "$MAIL\n"
    # # bindkey -s "^n" "khal calendar\n"

    # # eval "$(direnv hook zsh)"
  };
}
