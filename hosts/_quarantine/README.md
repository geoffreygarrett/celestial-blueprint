# Quarantined configuration

Inactive host configs and legacy cruft preserved for reference. Not wired in `flake.nix` outputs.

| Path | Former role |
|------|-------------|
| `cassini/` | Dell XPS 15 NixOS laptop |
| `mariner/` | Raspberry Pi k3s cluster |
| `nix-on-droid/` | Android nix-on-droid (pioneer, voyager) |
| `nix-on-droid-modules/` | nix-on-droid Home Manager modules |
| `shared-programs/` | Legacy duplicate HM program modules (canonical: `nix/users/geoffrey/home-manager/modules/`) |
| `graveyard/` | Retired module experiments |
| `dotfiles/` | Pre-flake nvim/alacritty copies |

Active k3 modules live at `nix/modules/nixos/k3/`. Starship config at `nix/users/geoffrey/home-manager/assets/starship/`.

To restore a host, move its directory to `hosts/<name>/` and re-add the flake output.
