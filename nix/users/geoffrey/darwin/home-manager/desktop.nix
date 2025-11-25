{
  pkgs,
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix

    # Add after this comment
    # Temporarily disabled due to writeShellScript using deprecated substituteAll
    # ./modules/wallpaper.nix
  ] ++ (import ../../home-manager/desktop.nix args).imports;
}
