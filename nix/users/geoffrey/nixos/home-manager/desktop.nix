{
  pkgs,
  lib,
  config,
  ...
}@args:
{
  imports = [
    ./shared.nix
    ../../home-manager/desktop.nix
    ../../../../modules/profiles/desktop-bspwm
    ./modules/sway.nix
    ./modules/robotics.nix
    ./modules/scarlett-focusrite.nix
  ];

  home.packages = with pkgs; [
    qalculate-qt
    mailspring
    gimp
    inkscape
    vlc
  ];
}
