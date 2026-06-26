{
  pkgs,
  inputs,
  keys,
  ...
}:
{
  system.stateVersion = "24.11";

  imports = [
    ./hardware.nix
    ./services.nix
  ];
}
