{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages { inherit pkgs; };
in
shared-packages
++ [
  fswatch
  dockutil
]
