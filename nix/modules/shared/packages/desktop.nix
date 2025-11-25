{ pkgs }:
with pkgs;
let
  shared-packages = import ./default.nix { inherit pkgs; };
in
shared-packages
++ [
  qemu_full
  tailscale # (Reqires root, breaks NixOnDroid), no access to netif's.
  lmstudio
  # Disk testing
  testdisk
  ddrescue
  # fio  # Temporarily disabled - doesn't support macOS (requires fuse)

  # Work
  spotify

  # Deploy
  deploy-rs

  # Networking
  iperf2
]
