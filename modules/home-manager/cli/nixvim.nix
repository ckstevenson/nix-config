{ pkgs, config, inputs, ... }:
let
  palette = config.colorScheme.palette;
in
{
  programs.nixvim = {
    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
    colorschemes.nightfox.enable = true;
    colorschemes.nightfox.flavor = "carbonfox";

    nixpkgs.config.allowUnfree = true;
    # Use unstable nixpkgs so nixvim's pkgs version matches its own module version.
    # mbp pins system nixpkgs to stable (25.11) via nixpkgs.pkgs override, but nixvim
    # evaluates with unstable (26.05) — using stable pkgs.path causes makeVimPackageInfo mismatch.
    nixpkgs.source = inputs.nixpkgs;

    # Set terminal colors to match the nix-colors palette
    # This ensures :terminal in Neovim uses the same colors as your external terminal
    extraConfigLua = ''
      -- ANSI terminal colors (0-7: normal, 8-15: bright)
      vim.g.terminal_color_0  = "#${palette.base00}" -- black
      vim.g.terminal_color_1  = "#${palette.base08}" -- red
      vim.g.terminal_color_2  = "#${palette.base0B}" -- green
      vim.g.terminal_color_3  = "#${palette.base0A}" -- yellow
      vim.g.terminal_color_4  = "#${palette.base0D}" -- blue
      vim.g.terminal_color_5  = "#${palette.base0E}" -- magenta
      vim.g.terminal_color_6  = "#${palette.base0C}" -- cyan
      vim.g.terminal_color_7  = "#${palette.base05}" -- white
      -- Bright variants
      vim.g.terminal_color_8  = "#${palette.base03}" -- bright black
      vim.g.terminal_color_9  = "#${palette.base08}" -- bright red
      vim.g.terminal_color_10 = "#${palette.base0B}" -- bright green
      vim.g.terminal_color_11 = "#${palette.base0A}" -- bright yellow
      vim.g.terminal_color_12 = "#${palette.base0D}" -- bright blue
      vim.g.terminal_color_13 = "#${palette.base0E}" -- bright magenta
      vim.g.terminal_color_14 = "#${palette.base0C}" -- bright cyan
      vim.g.terminal_color_15 = "#${palette.base06}" -- bright white
    '';

    filetype = {
      filename = {
        "user-data".__raw = ''
          function(path)
            local first_line = vim.fn.readfile(path, "", 1)[1] or ""
            if first_line:match("^<powershell>") then
              return "ps1"
            end
            return "yaml"
          end
        '';
      };
      pattern = {
        ".*.pkr.*" = "tf";
      };
    };
    #globals = {
    #  mapleader = " ";
    #};

    opts = {
      encoding = "utf-8";
      nu = true;
      relativenumber = true;
      hlsearch = false;
      belloff = "all";
      swapfile = false;
      undofile = true;
      scrolloff = 8;
      ff = "unix";
      autoindent = true;
      autoread = true;
      clipboard = "unnamedplus";
      smarttab = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      splitright = true;
      splitbelow = true;
      foldlevelstart = 99;
    };

    autoCmd = [
      {
        command = ''%s/\s\+$//e'';
        event = [ "BufWritePre" ];
        pattern = [ "*" ];
      }
      {
        command = "silent ! tofu fmt %:p";
        event = [ "BufWritePost" ];
        pattern = [
          "*.tf"
          "*.tfvars"
        ];
      }
      {
        command = "silent ! packer fmt %:p";
        event = [ "BufWritePost" ];
        pattern = [
          "*.pkr.hcl"
          "*.pkrvars.hcl"
        ];
      }
      # Enable folding for Terraform files
      {
        event = [ "FileType" ];
        pattern = [ "terraform" "tf" ];
        callback.__raw = ''
          function()
            vim.opt_local.foldmethod = "indent"
          end
        '';
      }
      # Auto-insert semicolon after {} in Nix files
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        callback.__raw = ''
          function()
            vim.keymap.set("i", "{", function()
              return "{};<Left><Left>"
            end, { expr = true, buffer = true, noremap = true })
            vim.keymap.set("i", "[", function()
              return "[];<Left><Left>"
            end, { expr = true, buffer = true, noremap = true })
          end
        '';
      }
    ];

    keymaps = [
      {
        action = ":! sudo nixos-rebuild switch --flake ~/nixos/hosts/#default<cr>";
        key = "<leader>oo";
      }
      {
        action = "*p";
        key = "<leader>p";
        options = {
          silent = true;
        };
      }
      {
        action = "gj";
        key = "j";
        options = {
          silent = true;
        };
      }
      {
        action = "gk";
        key = "k";
        options = {
          silent = true;
        };
      }
      {
        action = "g0";
        key = "0";
        options = {
          silent = true;
        };
      }
      {
        action = "g$";
        key = "$";
        options = {
          silent = true;
        };
      }

      {
        action = "<C-w><";
        key = "<C-10<";
        options = {
          silent = true;
        };
      }
      {
        action = "<C-w>>";
        key = "<C-10>";
        options = {
          silent = true;
        };
      }
      {
        action = ":bn<CR>";
        key = "<leader>bn";
        options = {
          silent = true;
        };
      }
      {
        action = ":bp<CR>";
        key = "<leader>bp";
        options = {
          silent = true;
        };
      }
      {
        action = ":bd<CR>";
        key = "<leader>bd";
        options = {
          silent = true;
        };
      }
      {
        action = ":vsplit <CR>";
        key = "<leader>sv";
        options = {
          silent = true;
        };
      }
      {
        action = ":split <CR>";
        key = "<leader>sh";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"vertical resize +5\"<CR>";
        key = "<C-S-l>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"vertical resize -5\"<CR>";
        key = "<C-S-h>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"resize +5\"<CR>";
        key = "<C-S-k>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"resize -5\"<CR>";
        key = "<C-S-j>";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>0G<CR>";
        key = "<leader>G";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>Gvdiffsplit<CR>";
        key = "<leader>gd";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>Telescope harpoon marks<CR>";
        key = "<leader>hm";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>";
        key = "<leader>gws";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktrees()<CR>";
        key = "<leader>gwc";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>LazyGit<CR>";
        key = "<leader>gl";
        options = {
          silent = true;
        };
      }
      {
        key = "<leader>ha";
        action.__raw = "function() require'harpoon':list():add() end";
      }
      {
        key = "<leader>hl";
        action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
      }
      {
        key = "<leader>1";
        action.__raw = "function() require'harpoon':list():select(1) end";
      }
      {
        key = "<leader>2";
        action.__raw = "function() require'harpoon':list():select(2) end";
      }
      {
        key = "<leader>3";
        action.__raw = "function() require'harpoon':list():select(3) end";
      }
      {
        key = "<leader>4";
        action.__raw = "function() require'harpoon':list():select(4) end";
      }
      {
        action = "<cmd>UndotreeToggle<cr>";
        key = "<leader>u";
      }
      # OpenCode keymaps
      {
        key = "<C-o>";
        mode = [ "n" "x" ];
        action.__raw = "function() require('opencode').ask('@this: ', { submit = true }) end";
        options = {
          desc = "Ask opencode";
        };
      }
      {
        key = "<leader>op";
        mode = [ "n" "x" ];
        action.__raw = "function() require('opencode').select() end";
        options = {
          desc = "Execute opencode action…";
        };
      }
      {
        key = "<leader>oa";
        mode = [ "n" "x" ];
        action.__raw = "function() require('opencode').prompt('@this') end";
        options = {
          desc = "Add to opencode";
        };
      }
      {
        key = "<leader>ot";
        mode = [ "n" "t" ];
        action.__raw = "function() require('opencode').toggle() end";
        options = {
          desc = "Toggle opencode";
          silent = true;
        };
      }
      {
        key = "<S-C-u>";
        mode = [ "n" ];
        action.__raw = "function() require('opencode').command('session.half.page.up') end";
        options = {
          desc = "opencode half page up";
        };
      }
      {
        key = "<S-C-d>";
        mode = [ "n" ];
        action.__raw = "function() require('opencode').command('session.half.page.down') end";
        options = {
          desc = "opencode half page down";
        };
      }
      # Terminal keymaps
      {
        key = "<leader>tv";
        mode = "n";
        action = "<cmd>vsplit | terminal<CR>";
        options = {
          desc = "Terminal vertical split";
          silent = true;
        };
      }
      {
        key = "<leader>th";
        mode = "n";
        action = "<cmd>split | terminal<CR>";
        options = {
          desc = "Terminal horizontal split";
          silent = true;
        };
      }
      {
        key = "<leader>tt";
        mode = "n";
        action = "<cmd>tabnew | terminal<CR>";
        options = {
          desc = "Terminal new tab";
          silent = true;
        };
      }
      {
        key = "<Esc>";
        mode = "t";
        action = "<C-\\><C-n>";
        options = {
          desc = "Exit terminal mode";
          silent = true;
        };
      }
    ];

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
            #{ name = "copilot"; }
          ];
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
          };
        };
        cmdline = {
          "/" = {
            mapping = {
              __raw = "cmp.mapping.preset.cmdline()";
            };
            sources = [
              {
                name = "buffer";
              }
            ];
          };
          ":" = {
            mapping = {
              __raw = "cmp.mapping.preset.cmdline()";
            };
            sources = [
              {
                name = "path";
              }
              {
                name = "cmdline";
                option = {
                  ignore_cmds = [
                    "Man"
                    "!"
                  ];
                };
              }
            ];
          };
        };
      };
      lsp = {
        enable = true;
        preConfig = ''
          vim.lsp.set_log_level('debug')
        '';
        keymaps.diagnostic = {
          "<leader>dn" = "goto_next";
          "<leader>dp" = "goto_prev";
          "<leader>do" = "open_float";
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gr" = "references";
          "gi" = "implementation";
          "K" = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
          "<leader>fs" = "document_symbol";
          "<leader>ws" = "workspace_symbol";
        };
        servers = {
          bashls.enable = true;
          omnisharp = {
            enable = true;
            package = pkgs.omnisharp-roslyn;
            cmd = [ "${pkgs.omnisharp-roslyn}/bin/OmniSharp" "-lsp" ];
          };
          cssls.enable = true;
          docker_compose_language_service.enable = true;
          dockerls.enable = true;
          gopls.enable = true;
          html.enable = true;
          jsonls.enable = true;
          lua_ls.enable = true;
          nixd.enable = true;
          #powershell_es.enable = true;
          pyright.enable = true;
          terraformls.enable = true;
          tflint.enable = true;
          ts_ls.enable = true;
          typos_lsp.enable = true;
        };
      };

      lualine = {
        enable = true;
        settings = {
          options.theme = {
            normal = {
              a = { fg = "#${palette.base00}"; bg = "#${palette.base0E}"; gui = "bold"; };
              b = { fg = "#${palette.base05}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base05}"; bg = "#${palette.base00}"; };
            };
            insert = {
              a = { fg = "#${palette.base00}"; bg = "#${palette.base0E}"; gui = "bold"; };
              b = { fg = "#${palette.base05}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base05}"; bg = "#${palette.base00}"; };
            };
            visual = {
              a = { fg = "#${palette.base00}"; bg = "#${palette.base0E}"; gui = "bold"; };
              b = { fg = "#${palette.base05}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base05}"; bg = "#${palette.base00}"; };
            };
            replace = {
              a = { fg = "#${palette.base00}"; bg = "#${palette.base0E}"; gui = "bold"; };
              b = { fg = "#${palette.base05}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base05}"; bg = "#${palette.base00}"; };
            };
            command = {
              a = { fg = "#${palette.base00}"; bg = "#${palette.base0E}"; gui = "bold"; };
              b = { fg = "#${palette.base05}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base05}"; bg = "#${palette.base00}"; };
            };
            inactive = {
              a = { fg = "#${palette.base03}"; bg = "#${palette.base01}"; };
              b = { fg = "#${palette.base03}"; bg = "#${palette.base01}"; };
              c = { fg = "#${palette.base03}"; bg = "#${palette.base00}"; };
            };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              {
                __unkeyed-1.__raw = ''
                  function()
                    local git_dir = vim.fn.FugitiveGitDir()
                    if git_dir == "" then
                      return ""
                    end
                    -- Check if we're in a worktree (git_dir contains /worktrees/)
                    if git_dir:find("/worktrees/") then
                      -- Extract project name: strip /worktrees/* then get parent dir name
                      local main_git_dir = git_dir:gsub("/worktrees/.*", "")
                      return vim.fn.fnamemodify(main_git_dir, ":h:t")
                    else
                      -- Regular repo: get parent of .git dir
                      return vim.fn.fnamemodify(git_dir, ":h:t")
                    end
                  end
                '';
                icon = "";
              }
            ];
            lualine_c = [
              {
                __unkeyed-1.__raw = ''
                  function()
                    local git_dir = vim.fn.FugitiveGitDir()
                    if git_dir == "" then
                      -- Not in a git repo, show relative path
                      return vim.fn.expand('%:~:.')
                    end
                    -- Get path relative to repo root
                    local file_path = vim.fn.expand('%:p')
                    local repo_root = vim.fn.FugitiveWorkTree()
                    if repo_root ~= "" and file_path:find(repo_root, 1, true) == 1 then
                      local rel_path = file_path:sub(#repo_root + 2)
                      return rel_path ~= "" and rel_path or vim.fn.expand('%:t')
                    end
                    return vim.fn.expand('%:t')
                  end
                '';
              }
            ];
            lualine_x = [ "diagnostics" "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      which-key = {
        enable = true;
      };

      telescope = {
        enable = true;
        extensions = {
          undo.enable = true;
          ui-select.enable = true;
          fzf-native.enable = true;
          advanced-git-search.enable = true;
        };
        #enabledExtensions = [
        #  "undo"
        #  "ui-select"
        #  "fzf-native"
        #  "advanced-git-search"
        #];
        keymaps = {
          "<Leader>ff" = {
            action = "find_files";
          };
          "<Leader>fh" = {
            action = "find_files hidden=true";
          };
          "<Leader>fg" = {
            action = "live_grep";
          };
          "<Leader>fb" = {
            action = "buffers";
          };
          "<Leader>f?" = {
            action = "help_tags";
          };
          "<Leader>fm" = {
            action = "marks";
          };
          "<Leader>gg" = {
            action = "git_files";
          };
          "<Leader>gc" = {
            action = "git_commits";
          };
          "<Leader>gb" = {
            action = "git_branches";
          };
          "<Leader>gs" = {
            action = "git_status";
          };
          "<Leader>ft" = {
            action = "treesitter";
          };
          "<Leader>dd" = {
            action = "diagnostics";
          };
        };
      };

      git-worktree = {
        enable = true;
        enableTelescope = true;
        settings.autopush = true;
      };

      harpoon.enable = true;
      dap.enable = true;
      autoclose = {
        enable = true;
        settings = {
          options = {
            disabled_filetypes = [
              "text"
              "markdown"
            ];
          };
          touch_regex = "[%w(%[{]";
          keys = {
            "{" = {
              escape = false;
              close = true;
              pair = "{}";
              disabled_filetypes = [ "nix" ];
            };
          };
        };
      };
      #copilot-vim.enable = true;
      #copilot-chat = {
      #  enable = false;
      #  settings = {
      #    model = "claude-sonnet-4";
      #    mappings = {
      #      complete = {
      #        insert = "<S-Tab>";
      #      };
      #    };
      #  };
      #};
      #diagram.enable = true;
      #dotnet.enable = true;
      markview.enable = true;
      fugitive.enable = true;
      gitignore.enable = true;
      gitblame.enable = true;
      lazygit.enable = false;
      luasnip.enable = true;
      opencode = {
        enable = true;
        #settings = {
        #  # Ensure OpenCode uses system colors and inherits terminal theme
        #  theme = "system";
        #};
      };
      snacks = {
        enable = true;
        settings = {
          input.enabled = true;
          picker.enabled = true;
          terminal.enabled = true;
        };
      };
      colorizer.enable = true;
      treesitter.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      undotree = {
        enable = false;
        settings = {
          SplitWidth = 40;
          SetFocusWhenToggle = true;
        };
      };
      toggleterm = {
        enable = false;
        settings = {
          direction = "float";
          float_opts = {
            border = "curved";
            height = 40;
            width = 150;
          };
          open_mapping = "[[<c-CR>]]";
        };
      };
    };
  };
}
