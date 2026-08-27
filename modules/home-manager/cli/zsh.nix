{ config, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    # Make Ctrl+W stop at slashes and common delimiters
    # Removes / from default WORDCHARS so paths are deleted segment by segment
    localVariables.WORDCHARS = "*?_-.[]~=&;!#$%^(){}<>";

    setOptions = [ "prompt_subst" ];

    history = {
      size = 10000;
      save = 10000;
      extended = true;
      ignoreSpace = true;
    };

    initContent = with config.colorScheme.palette; ''
      bindkey '^ ' autosuggest-execute
      bindkey '^R' history-incremental-pattern-search-backward

      bindkey "^A" vi-beginning-of-line
      bindkey "^E" vi-end-of-line

      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # prompt
      autoload -Uz vcs_info
      precmd_vcs_info() { vcs_info }
      precmd_functions+=( precmd_vcs_info )

      # Git status indicators: (branch)[+!$] format - staged green +, unstaged red !, stash yellow $
      # Brackets only shown when there are changes
      zstyle ':vcs_info:git:*' check-for-changes true
      zstyle ':vcs_info:git:*' stagedstr '%F{#${base0B}}+%f'
      zstyle ':vcs_info:git:*' unstagedstr '%F{#${base08}}!%f'
      zstyle ':vcs_info:git:*' formats ' %F{#${base0D}}(%b)%f%c%u%m'
      zstyle ':vcs_info:git:*' actionformats ' %F{#${base0D}}(%b)%f%c%u%m %F{#${base08}}[%a]'

      # Hook to check for stashed changes
      +vi-git-stash() {
        if git rev-parse --verify refs/stash &>/dev/null; then
          hook_com[misc]='%F{#${base0A}}$%f'
        fi
      }

      # Hook to wrap status indicators in brackets
      +vi-git-status-brackets() {
        if [[ -n "$hook_com[staged]" || -n "$hook_com[unstaged]" || -n "$hook_com[misc]" ]]; then
          hook_com[staged]="[''${hook_com[staged]}"
          if [[ -n "$hook_com[misc]" ]]; then
            hook_com[misc]="''${hook_com[misc]}]"
          elif [[ -n "$hook_com[unstaged]" ]]; then
            hook_com[unstaged]="''${hook_com[unstaged]}]"
          else
            hook_com[staged]="''${hook_com[staged]}]"
          fi
        fi
      }
      zstyle ':vcs_info:git+set-message:*' hooks git-stash git-status-brackets

      # Smart path: full path from repo root in git, otherwise last 2 segments
      # Handles worktrees (including bare repo setups with .bare directory)
      _smart_path() {
        local git_dir=$(git rev-parse --git-dir 2>/dev/null)

        # Not in a git repo
        if [[ -z "$git_dir" ]]; then
          print -P '%2~'
          return
        fi

        local repo_name rel_path

        # Check if we're in a worktree (git_dir contains /worktrees/)
        if [[ "$git_dir" == *"/worktrees/"* ]]; then
          # Extract project name: strip /worktrees/* and get parent dir name
          # Handles both .git/worktrees and .bare/worktrees
          local base_dir=''${git_dir%/worktrees/*}
          base_dir=''${base_dir%/.bare}
          base_dir=''${base_dir%/.git}
          repo_name=''${base_dir:t}
          rel_path=$(git rev-parse --show-prefix 2>/dev/null)
        # Check if in a bare repo (not a work tree)
        elif [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) != "true" ]]; then
          # In bare repo root, use current directory name
          repo_name=''${PWD:t}
          rel_path=""
        else
          # Regular repo
          local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
          repo_name=''${repo_root:t}
          rel_path=$(git rev-parse --show-prefix 2>/dev/null)
        fi

        rel_path=''${rel_path%/}

        if [[ -n "$rel_path" ]]; then
          echo "''${repo_name}/''${rel_path}"
        else
          echo "''${repo_name}"
        fi
      }

      # Report repository name separately so Herdr does not display worktree basename.
      _herdr_repo_metadata() {
        [[ -z "$HERDR_WORKSPACE_ID" ]] && return

        local common_dir repo_name
        common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return
        common_dir=''${common_dir:A}
        repo_name=''${common_dir:t}

        if [[ "$repo_name" == ".git" || "$repo_name" == ".bare" ]]; then
          repo_name=''${common_dir:h:t}
        fi

        [[ -z "$repo_name" ]] && return
        herdr workspace report-metadata "$HERDR_WORKSPACE_ID" \
          --source zsh-repo-name --token "repo=$repo_name" >/dev/null 2>&1
      }
      precmd_functions+=( _herdr_repo_metadata )

      # Nix shell indicator
      _nix_shell_indicator() {
        [[ -n "$IN_NIX_SHELL" ]] && echo " %F{#${base0D}}❄%f"
      }

      # Prompt character: base0B normally, red on error
      _prompt_char() {
        echo "%(?.%F{#${base0B}}.%F{#${base08}})>%f"
      }

      PROMPT='%F{magenta}$(_smart_path)''${vcs_info_msg_0_}$(_nix_shell_indicator) $(_prompt_char) '
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
  };
}
