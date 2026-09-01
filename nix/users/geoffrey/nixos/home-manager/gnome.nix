# Home-manager layer for the GNOME desktop (cassini).
#
# Deliberately parallel to ./desktop.nix rather than a modification of it:
# desktop.nix drives the bspwm/polybar/skhd stack, which stays intact and
# unbuilt so switching back is a one-line change in flake.nix.
{
  pkgs,
  ...
}:

let
  wallpaper = ../../../../modules/shared/assets/wallpaper/deep-ocean-wallpaper.png;
in
{
  imports = [
    ./shared.nix
    ../../home-manager/desktop.nix # nixvim, alacritty, firefox — WM-agnostic
    ./webapps.nix # Claude + ChatGPT: no native Linux app exists
    ./work-apps.nix # what artemis is actually used for
  ];

  home.packages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
  ];

  dconf.settings = {
    # --- Deep Ocean ---------------------------------------------------------
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
      picture-options = "zoom";
      primary-color = "#0F111A"; # base00
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${wallpaper}";
      primary-color = "#0F111A";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      accent-color = "teal"; # nearest GNOME accent to base07 #84FFFF
      font-name = "Cantarell 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      clock-show-weekday = true;
      show-battery-percentage = true;
      enable-hot-corners = false;
    };

    # --- macOS-shaped input -------------------------------------------------
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      disable-while-typing = true;
    };

    # --- window management --------------------------------------------------
    # GNOME's power plugin is independent of logind; both must be set or the
    # session still suspends on idle.
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 1800;
      power-button-action = "interactive";
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:"; # buttons on the left, macOS-style
      focus-mode = "click";
    };

    # --- dock ---------------------------------------------------------------
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "cursor.desktop"
        "claude-code.desktop"
        "claude-web.desktop"
        "chatgpt-web.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      extend-height = false;
      dash-max-icon-size = 44;
      autohide = true;
      intellihide = true;
      show-mounts = false;
      show-trash = false;
      transparency-mode = "DYNAMIC";
      running-indicator-style = "DOTS";
      click-action = "minimize-or-previews";
    };
  };
}
