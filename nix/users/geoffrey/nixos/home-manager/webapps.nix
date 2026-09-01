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

  mkWebApp =
    {
      id,
      name,
      url,
      icon,
      comment,
    }:
    {
      inherit name comment icon;
      # Separate --user-data-dir per app: independent logins, and GNOME treats
      # each as its own application rather than lumping them under Chromium.
      exec = "${browser} --app=${url} --class=${id} --user-data-dir=$HOME/.local/share/webapps/${id}";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "Development"
      ];
      settings.StartupWMClass = id;
    };
in
{
  home.packages = [ pkgs.chromium ];

  xdg.desktopEntries = {
    claude-web = mkWebApp {
      id = "claude-web";
      name = "Claude";
      url = "https://claude.ai/new";
      comment = "Claude (web app)";
      icon = ../../../../modules/shared/assets/icons/claude.png;
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
