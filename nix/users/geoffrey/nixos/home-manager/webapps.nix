# Desktop entries for AI assistants that have no native Linux app.
#
# Neither OpenAI nor Anthropic ships a Linux desktop build:
#   nixpkgs.chatgpt        -> meta.platforms = darwin only
#   claude-desktop         -> not packaged at all
#
# Rather than repackage a Windows build (fragile, breaks on every upstream
# release), these run the real web apps in their own Chromium window with a
# dedicated profile. They get a proper icon, their own taskbar entry, and
# they self-update because they *are* the web app.
{
  pkgs,
  ...
}:

let
  browser = "${pkgs.chromium}/bin/chromium";

  # The desktop-entry spec forbids '$' in Exec, so $HOME cannot be expanded
  # there. Wrap the invocation in a script instead.
  mkWebApp =
    {
      id,
      name,
      url,
      icon,
      comment,
    }:
    let
      launcher = pkgs.writeShellScript "webapp-${id}" ''
        exec ${browser} \
          --app=${url} \
          --class=${id} \
          --user-data-dir="$HOME/.local/share/webapps/${id}" \
          "$@"
      '';
    in
    {
      inherit name comment icon;
      # Separate --user-data-dir per app: independent logins, and GNOME treats
      # each as its own application rather than lumping them under Chromium.
      exec = "${launcher}";
      terminal = false;
      type = "Application";
      # Exactly one main category, or desktop-file-validate warns about the
      # app appearing twice in the menu.
      categories = [ "Network" ];
      settings.StartupWMClass = id;
    };
in
{
  home.packages = with pkgs; [
    chromium
    code-cursor # 3.7.19 — real Linux build, unlike the other two
  ];

  xdg.desktopEntries = {
    claude-web = mkWebApp {
      id = "claude-web";
      name = "Claude";
      url = "https://claude.ai/new";
      comment = "Claude (web app)";
      icon = ../../../../modules/shared/assets/icons/claude.png;
    };

    # claude-code is a CLI with no .desktop of its own, so it can never show
    # up in a launcher. Give it one that opens a terminal straight into it.
    claude-code = {
      name = "Claude Code";
      comment = "Claude Code CLI in a terminal";
      exec = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.claude-code}/bin/claude";
      icon = ../../../../modules/shared/assets/icons/claude.png;
      terminal = false;
      type = "Application";
      categories = [ "Development" ];
      settings.StartupWMClass = "com.mitchellh.ghostty";
    };

    chatgpt-web = mkWebApp {
      id = "chatgpt-web";
      name = "ChatGPT";
      url = "https://chatgpt.com/";
      comment = "ChatGPT (web app)";
      icon = ../../../../modules/shared/assets/icons/chatgpt.png;
    };
  };
}
