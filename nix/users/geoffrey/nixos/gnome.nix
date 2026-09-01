# GNOME desktop for cassini (Dell XPS 15 9560).
#
# Sits alongside ./desktop.nix (bspwm) rather than replacing it. Switch between
# them by changing which one flake.nix imports for the host — the bspwm profile,
# polybar config and skhd bindings remain in the tree, unbuilt.
#
# Rationale: GNOME needs no memorised keybindings and maps onto macOS habits
# (overview = Mission Control, Super = Spotlight, 3-finger workspace swipes).
{
  pkgs,
  ...
}:

{
  imports = [
    ./shared.nix
    ./modules/theming.nix # GTK/Qt/portals — DE-agnostic, reused as-is
    ./modules/xdg-mime.nix
    ./modules/samba.nix
  ];

  home-manager = {
    users."geoffrey" = import ./home-manager/gnome.nix;
  };

  # --- desktop --------------------------------------------------------------
  services.xserver.enable = true; # still required for XWayland
  services.xserver.exportConfiguration = true;
  services.xserver.xkb.options = "ctrl:swapcaps";
  console.useXkbConfig = true;

  # GNOME 50 is Wayland-only; gdm.wayland was removed as an option.
  # Wayland is what gives the macOS-style three-finger gestures.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME ships a lot we do not want on a work laptop.
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    totem
    gnome-music
    gnome-contacts
    gnome-maps
    gnome-weather
    simple-scan
  ];

  # --- laptop niceties ------------------------------------------------------
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
  services.tumbler.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # --- packages -------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    baobab
  ];

  users.users.geoffrey.packages = with pkgs; [
    claude-code # CLI, 2.1.177
    code-cursor # Cursor editor, 3.7.19 — the only one of the three with a real Linux build
    ghostty
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    cantarell-fonts
  ];
}
