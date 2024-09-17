{
  config,
  user,
  pkgs,
  ...
}:
let
  icon-files = import ../shared/files/icons.nix { inherit user pkgs; };
in
icon-files
// {
  "local/share/applications/alacritty-neovim.desktop" = {
    text = ''
      [Desktop Entry]
      Version=1.0
      Name=Alacritty with Neovim
      Comment=Open files with Neovim inside Alacritty
      Exec=${pkgs.alacritty}/bin/alacritty -e ${pkgs.neovim}/bin/nvim %F
      Terminal=false
      Type=Application
      MimeType=text/plain;application/x-shellscript;
      Icon=local/share/icons/alacritty_flat_512.png
      Categories=Utility;TextEditor;
    '';
  };
}
