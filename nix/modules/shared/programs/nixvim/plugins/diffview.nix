{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      package = pkgs.vimPlugins.diffview-nvim;
      settings = {
        diff_binaries = false;
        disable_default_keymaps = false;
        enhanced_diff_hl = false;
        git_cmd = [ "git" ];
        hg_cmd = [ "hg" ];
        show_help_hints = true;
        use_icons = true;
        watch_index = true;
      };
    };

    # You can add extra configuration if needed
    extraConfigLua = ''
      -- Add any additional Lua configuration for diffview here
    '';
  };
}
