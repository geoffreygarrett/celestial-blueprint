{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages/desktop.nix { inherit pkgs; };
in
shared-packages
++ [
  pinentry-curses
  mendeley
  ddrescueview
  #  pcscd https://discourse.nixos.org/t/home-manager-users-can-help-test-gnupg-2-3-1-beta/12692/5
]
