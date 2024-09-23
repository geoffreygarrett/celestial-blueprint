{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = false;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
  };
}
