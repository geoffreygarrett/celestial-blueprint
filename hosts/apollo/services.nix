# Host services, networking, and desktop stack for apollo.
{
  user,
  pkgs,
  inputs,
  keys,
  ...
}:
let
  hostname = "apollo";
  mainInterface = "eno2";
in
{
  programs.steam.enable = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --primary
  '';

  home-manager.useGlobalPkgs = true;

  imports = [
    inputs.nixus.nixosModules.spotify
    ../../nix/modules/nixos/openrgb.nix
    ../../nix/modules/nixos/openssh.nix
    ../../nix/modules/nixos/tailscale.nix
    ../../nix/modules/nixos/samba.nix
    ../../nix/modules/nixos/k3/agent.nix
    ./k3s.nix
    ../../nix/modules/nixos/shared-hosts.nix
    ./config/desktop.nix
    ../../nix/users/geoffrey/nixos/desktop.nix
    ../../nix/scripts/network-tools.nix
    ./modules/autorandr.nix
  ];

  services.networkTools.enable = true;
  nix.settings.secret-key-files = "/etc/nix/cache-priv-key.pem";

  nixus.spotify = {
    enable = true;
    useNerdFonts = true;
    firewall = {
      enableLocalDiscovery = true;
      enableLocalSync = true;
      enableSpotifyConnect = true;
      acknowledgeFirewallRisks = true;
    };
  };

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.zsh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = keys;

  systemd.services.wakeonlan = {
    description = "Reenable wake on lan every boot";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "true";
      ExecStart = "${pkgs.ethtool}/sbin/ethtool -s ${mainInterface} wol g";
    };
    wantedBy = [ "default.target" ];
  };

  environment.systemPackages = with pkgs; [
    jdk17
    sops
  ];

  nix.settings.trusted-users = [
    "root"
    "geoffrey"
  ];

  console.earlySetup = true;

  boot.loader.timeout = 5;
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "max";
    systemd-boot.configurationLimit = 3;
    efi = {
      canTouchEfiVariables = true;
    };
    grub.enable = false;
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    interfaces."${mainInterface}".wakeOnLan.enable = true;
    useDHCP = false;
    dhcpcd.wait = "background";
    firewall = {
      enable = true;
      allowedUDPPorts = [ ];
      allowedTCPPorts = [
        22
        80
        443
        9123
      ];
    };
  };
}
