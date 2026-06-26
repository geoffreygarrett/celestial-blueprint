{ lib, ... }:

{
  nix.enable = lib.mkDefault true; # required by nix-darwin linux-builder assertion

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    builders-use-substitutes = true;
    accept-flake-config = true;
  };

  nix.linux-builder.enable = true;
  nix.linux-builder.systems = [ "aarch64-linux" ];

  # P3: nix.linux-builder.config added only after P2 passes
}