{
  pkgs,
  ...
}:
let
  name = "geoffrey";
  description = "Geoffrey Garrett";
  keys = import ./keys.nix;
in
{
  home-manager.backupFileExtension = ".bak";
  users.users.${name} = {
    inherit name description;
    shell = pkgs.zsh;
    openssh.authorizedKeys = {
      inherit keys;
    };
    packages = with pkgs; [
      git
      # usbutils
      # pciutils
    ];
  };
  programs.zsh.enable = true; # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.enable
  programs.direnv.enable = true; # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.direnv.enable
  environment.systemPackages = with pkgs; [
    # gitAndTools.gitFull
    # inetutils
  ];
}
