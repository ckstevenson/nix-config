{ ... }:
{
  programs.nixvim = {
  #

    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
    colorschemes.nightfox.enable = true;
    colorschemes.nightfox.flavor = "carbonfox";
    #colorschemes.base16.enable = true;
    #colorschemes.base16.colorscheme = {
    #  base00 = "#161616";
    #  base01 = "#262626";
    #  base02 = "#393939";
    #  base03 = "#525252";
    #  base04 = "#dde1e6";
    #  base05 = "#f2f4f8";
    #  base06 = "#ffffff";
    #  base07 = "#08bdba";
    #  base08 = "#ff7eb6";
    #  base09 = "#78a9ff";
    #  base0A = "#FFCB6B";
    #  base0B = "#42be65";
    #  base0C = "#3ddbd9";
    #  base0D = "#33b1ff";
    #  base0E = "#be95ff";
    #  base0F = "#82cfff";
    #};

    nixpkgs.config.allowUnfree = true;

    filetype = {
      filename ={
        "user-data" = "yaml";
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
      clipboard = "unnamedplus";
      smarttab = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      splitright = true;
      splitbelow = true;
    };

    autoCmd = [
      {
        command = ''%s/\s\+$//e'';
        event = ["BufWritePre"];
        pattern = ["*"];
      }
      {
        command = "silent ! tofu fmt %:p";
        event = ["BufWritePost"];
        pattern = [
          "*.tf"
          "*.tfvars"
        ];
      }
      {
        command = "silent ! packer fmt %:p";
        event = ["BufWritePost"];
        pattern = [
          "*.pkr.hcl"
          "*.pkrvars.hcl"
        ];
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
        action = "<C-w>j";
        key = "<C-j>";
        options = {
          silent = true;
        };
      }
      {
        action = "<C-w>h";
        key = "<C-h>";
        options = {
          silent = true;
        };
      }
      {
        action = "<C-w>k";
        key = "<C-k>";
        options = {
          silent = true;
        };
      }
      {
        action = "<C-w>l";
        key = "<C-l>";
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
        action = "<cmd>CopilotChat<CR>";
        key = "<C-o>";
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
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              })
            '';
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
      lsp ={
          enable = true;
          preConfig = ''
            vim.lsp.set_log_level('off')
          '';
          keymaps.diagnostic = {
            "<leader>dn" = "goto_next";
            "<leader>dp" = "goto_prev";
            "<leader>do" = "open_float";
          };
          servers = {
            ansiblels.enable = true;
            bashls.enable = true;
            #csharp_ls.enable = true;
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
        settings ={
          options.theme = "ayu_mirage";
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
            disable_filetype = [
              "text"
              "markdown"
            ];
          };
          touch_regex = "[%w(%[{]";
        };
      };
      copilot-vim.enable = true;
      copilot-chat = {
        enable = true;
        settings = {
          model = "claude-sonnet-4";
          mappings = {
             complete = {
               insert = "<S-Tab>";
             };
          };
        };
      };
      markview.enable = true;
      fugitive.enable = true;
      gitignore.enable = true;
      gitblame.enable = true;
      lazygit.enable = false;
      luasnip.enable = true;
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
