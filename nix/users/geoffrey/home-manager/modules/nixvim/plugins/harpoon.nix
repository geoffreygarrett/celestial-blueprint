{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.harpoon.enable = true;
    # plugins.harpoon = {
    #   enable = true;
    #   enableTelescope = true;
    #   keymapsSilent = true;
    #   keymaps = {
    #     addFile = "<leader>ha";
    #     toggleQuickMenu = "<leader>hm";
    #     navFile = {
    #       "1" = "<leader>h1";
    #       "2" = "<leader>h2";
    #       "3" = "<leader>h3";
    #       "4" = "<leader>h4";
    #     };
    #     navNext = "<leader>hn";
    #     navPrev = "<leader>hp";
    #     cmdToggleQuickMenu = "<leader>hc";
    #   };
    # };

    extraConfigLua = ''
      -- Setup harpoon after plugins are loaded
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local harpoon_ok, harpoon = pcall(require, "harpoon")
          if not harpoon_ok then
            return
          end

          -- Harpoon setup
          harpoon.setup({
            global_settings = {
              save_on_toggle = false,
              save_on_change = true,
              enter_on_sendcmd = false,
              tmux_autoclose_windows = false,
              excluded_filetypes = { "harpoon" },
              mark_branch = true,
              tabline = true,
              tabline_prefix = "   ",
              tabline_suffix = "   ",
            },
            menu = {
              width = vim.api.nvim_win_get_width(0) - 4,
            }
          })

          -- Safely require harpoon modules
          local mark_ok, mark = pcall(require, 'harpoon.mark')
          local ui_ok, ui = pcall(require, 'harpoon.ui')
          local cmd_ui_ok, cmd_ui = pcall(require, 'harpoon.cmd-ui')
          local term_ok, term = pcall(require, 'harpoon.term')

          if not (mark_ok and ui_ok and cmd_ui_ok and term_ok) then
            vim.notify("Harpoon modules not available", vim.log.levels.WARN)
            return
          end

          -- Key mappings
          vim.keymap.set('n', '<leader>ha', mark.add_file, { desc = "[H]arpoon: [A]dd file" })
          vim.keymap.set('n', '<leader>hm', ui.toggle_quick_menu, { desc = "[H]arpoon: Toggle [M]enu" })
          vim.keymap.set('n', '<leader>hc', cmd_ui.toggle_quick_menu, { desc = "[H]arpoon: Toggle [C]ommand menu" })

          -- Navigation
          vim.keymap.set('n', '<leader>hn', ui.nav_next, { desc = "[H]arpoon: [N]ext mark" })
          vim.keymap.set('n', '<leader>hp', ui.nav_prev, { desc = "[H]arpoon: [P]revious mark" })

          for i = 1, 4 do
            vim.keymap.set('n', string.format('<leader>h%s', i),
              function() ui.nav_file(i) end,
              { desc = string.format("[H]arpoon: Go to file %s", i) }
            )
          end

          -- Terminal commands
          vim.keymap.set('n', '<leader>ht1', function() term.gotoTerminal(1) end, { desc = "[H]arpoon: Go to [T]erminal 1" })
          vim.keymap.set('n', '<leader>ht2', function() term.gotoTerminal(2) end, { desc = "[H]arpoon: Go to [T]erminal 2" })
          vim.keymap.set('n', '<leader>hsc', function() term.sendCommand(1, 'ls -la') end, { desc = "[H]arpoon: [S]end [C]ommand to terminal 1" })

          -- Telescope integration
          local telescope_ok, telescope = pcall(require, 'telescope')
          if telescope_ok then
            telescope.load_extension('harpoon')
            vim.keymap.set('n', '<leader>hf', "<cmd>Telescope harpoon marks<CR>", { desc = "[H]arpoon: [F]ind marks in Telescope" })
          end

          -- Custom highlights for tabline
          vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#63698c')
          vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
          vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7')
          vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7')
          vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
        end,
      })

      -- Fallback: if VeryLazy event doesn't fire, try VimEnter
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          -- Trigger VeryLazy if it hasn't fired yet
          vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
        end,
      })
    '';
  };
}
