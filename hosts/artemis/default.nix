{
  pkgs,
  ...
}:
{
  imports = [
    ../../nix/modules/darwin/home-manager.nix
    ../../nix/modules/shared/cachix
    ../../nix/modules/shared
    ../../nix/modules/darwin
    ../../nix/users/geoffrey/darwin/desktop.nix
  ];

  environment.systemPackages =
    with pkgs;
    [ ] ++ (import ../../nix/modules/shared/packages { inherit pkgs; });
}
