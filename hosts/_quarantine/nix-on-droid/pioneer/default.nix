{ pkgs, ... }:
{
  imports = [
    ../shared.nix
  ];

  user = {
    uid = 10701;
    gid = 10701;
  };

  environment.sessionVariables = {
    hostname = "pioneer";
    HOSTNAME = "pioneer";
    HOST = "pioneer";
  };

  environment.packages = [
    (pkgs.writeShellScriptBin "hostname" ''
      echo "pioneer"
    '')
  ];
}
