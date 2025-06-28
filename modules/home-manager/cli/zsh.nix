{ ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "viins";
    shellAliases = {
    };
  };

  programs.zsh.initContent = ''
    bindkey '^ ' autosuggest-execute
    bindkey -v
    # bring back my bash habits
    bindkey "^[[1;5C" forward-word
    bindkey "^[[1;5D" backward-word
    bindkey "^A" vi-beginning-of-line
    bindkey "^E" vi-end-of-line

    #HISTFILE=~/.cache/zsh/history
    HISTSIZE=100000
    SAVEHIST=100000

    autoload -U colors && colors

    # completions baybay
    autoload -U compinit && compinit -u
    autoload bashcompinit && bashcompinit
    # Auto complete with case insenstivity

    zmodload zsh/complist
    compinit
    _comp_options+=(globdots)		# Include hidden files.
    # use the vi navigation keys in menu completion
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history

    # ability to delete chars in vi mode
    bindkey "^?" backward-delete-char

    # prompt
    autoload -Uz vcs_info
    precmd_vcs_info() { vcs_info }
    precmd_functions+=( precmd_vcs_info )
    zstyle ':vcs_info:git:*' formats ' %F{red}%r on %F{cyan}%b'
    setopt prompt_subst
    PROMPT='%F{blue}%m %F{magenta}%2~'\$vcs_info_msg_0_' %F{yellow}>%f '

    # Enable searching through history
    bindkey '^R' history-incremental-pattern-search-backward

    # ci", ci', ci`, di", etc
    autoload -U select-quoted
    zle -N select-quoted
    for m in visual viopp; do
      for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
      done
    done

    # Control bindings for programs
    bindkey -s "^b" "bc -l\n"
    bindkey -s "^f" "$FILE\n"
    #bindkey -s "^m" "$MAIL\n"
    bindkey -s "^n" "khal calendar\n"

    eval "$(direnv hook zsh)"

  '';
}
