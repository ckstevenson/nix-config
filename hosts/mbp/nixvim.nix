{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
    #clipboard.providers.wl-copy.enable = true;
    #wl-copy, wl-paste (if $WAYLAND_DISPLAY is set)
    colorschemes.oxocarbon.enable = true;

    filetype = {
      filename ={
        "user-data" = "yaml";
      };
      pattern = {
        ".*.pkr.*" = "tf";
      };
    };
    globals = {
      mapleader = " ";
    };

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
        command = "silent ! terraform fmt %:p";
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
      #{
      #  action = ":vsplit term://zsh<cr>";
      #  key = "<leader><enter>";
      #  options = {
      #    silent = true;
      #  };
      #}
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
        key = "<C-A-l>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"vertical resize -5\"<CR>";
        key = "<C-A-h>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"resize +5\"<CR>";
        key = "<C-A-k>";
        options = {
          silent = true;
        };
      }
      {
        action = ":exe \"resize -5\"<CR>";
        key = "<C-A-j>";
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
        key = "<leader>hs";
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
            {
              name = "nvim_lsp";
            }
            {
              name = "luasnip";
            }
            {
              name = "path";
            }
            {
              name = "buffer";
            }
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
          servers = {
            ansiblels.enable = true;
            bashls.enable = true;
            csharp-ls.enable = true;
            cssls.enable = true;
            docker-compose-language-service.enable = true;
            dockerls.enable = true;
            gopls.enable = true;
            html.enable = true;
            jsonls.enable = true;
            lua-ls.enable = true;
            nixd.enable = true;
            pyright.enable = true;
            terraformls.enable = true;
            tflint.enable = true;
            typos-lsp.enable = true;
          };
      };

      lualine = {
        enable = true;
        settings.options.theme = "ayu_mirage";
      };

      which-key = {
        enable = true;
      };

      telescope = {
        enable = true;
        keymaps = {
          "<Leader>ff" = {
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
        };
      };

      harpoon = {
        enable = true;
        keymaps = {
	        addFile = "<leader>ha";
	        cmdToggleQuickMenu = "<leader>hm";
          navFile = {
            "1" = "<leader>h1";
            "2" = "<leader>h2";
            "3" = "<leader>h3";
            "4" = "<leader>h4";
          };
          navNext = "<leader>hn";
          navPrev = "<leader>hp";
          gotoTerminal =  {
            "1" = "<leader>ht";
          };
        };
      };

      git-worktree = {
        enable = true;
        enableTelescope = true;
        autopush = true;
      };

      autoclose.enable = true;
      copilot-vim.enable = true;
      fugitive.enable = true;
      gitignore.enable = true;
      lazygit.enable = true;
      luasnip.enable = true;
      nvim-colorizer.enable = true;
      treesitter.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          float_opts = {
            border = "curved";
            height = 30;
            width = 130;
          };
          open_mapping = "[[<leader><enter>]]";
        };
      };
    };
  };
}