{
  pkgs,
  inputs,
  user,
  ...
}:
{
  home.stateVersion = "24.11";
  system.os = "linux";
  imports = [
    ../../users/geoffrey/home-manager/shared.nix
    ../shared/secrets.nix
    ../shared/aliases.nix
  ];
  programs.bash = {
    enable = true;
  };
  home.packages = import ./packages.nix { inherit pkgs; };
}
