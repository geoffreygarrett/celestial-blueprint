{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil writeShellScript;

  # Function to escape spaces in paths
  escapePath = path: ''"${lib.escape [ ''"'' ] path}"'';

  # Function to get the app name from the path
  getAppName =
    path:
    let
      basename = builtins.baseNameOf (lib.removeSuffix "/" path);
    in
    lib.removeSuffix ".app" basename;

in
{
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin;
      example = false;
    };

    local.dock.entries = mkOption {
      description = "Entries on the Dock";
      type =
        with types;
        listOf (submodule {
          options = {
            path = lib.mkOption { type = str; };
            section = lib.mkOption {
              type = str;
              default = "apps";
            };
            options = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
      readOnly = true;
    };
  };

  config = mkIf cfg.enable (
    # Temporarily disabled due to writeShellScript using deprecated substituteAll
    # TODO: Re-enable once nixpkgs fixes writeShellScript or we create a custom version
    {
      # system.activationScripts.dockSetup = {
      #   text = "";
      #   deps = [ ];
      # };
    }
  );
}
