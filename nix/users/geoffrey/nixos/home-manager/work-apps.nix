# Tools needed to keep working while artemis is being repaired.
#
# Derived from what is actually in use on artemis: running processes, plus
# ~/Library/Application Support directories touched in the last 14 days --
# not simply everything that happens to be installed.
{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # --- blocking without them -------------------------------------------
    nordpass # 6.5.20 — password manager; nothing else can be logged into first
    obsidian # 1.12.7 — notes

    # --- comms ------------------------------------------------------------
    slack
    telegram-desktop
    discord
    zoom-us

    # --- development ------------------------------------------------------
    insomnia # REST client
    postman
    # TablePlus's Linux .deb 404s -- upstream overwrites release URLs, so the
    # pinned hash rots. dbeaver covers the same Postgres/MySQL work.
    dbeaver-bin
    beekeeper-studio
    gitkraken
    ollama # local models
    ngrok
    wireshark
    gh
    lazygit

    # --- domain-specific --------------------------------------------------
    winbox # 4.1 — MikroTik, matches the router work on artemis
    prusa-slicer # OrcaSlicer is not packaged; this reads the same 3MF/STL
    freecad

    # --- launcher ---------------------------------------------------------
    # Raycast is macOS-only. GNOME's Super-key search already covers most of
    # what you use it for; ulauncher is here if you want the closer analogue.
    ulauncher

    # Heavy, uncomment when actually needed rather than paying for them now:
    # android-studio   # ~8 GB
    # davinci-resolve  # ~5 GB, and needs a GPU for anything real
    # blender
  ];
}
