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
  hyperfluent-theme = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "v1.0.1";
    sha256 = "0gyvms5s10j24j9gj480cp2cqw5ahqp56ddgay385ycyzfr91g6f";
  };
in
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.autorandr = {
    enable = true;
    defaultTarget = "dual-monitor";
    profiles = {
      "dual-monitor" = {
        fingerprint = builtins.fromJSON (builtins.readFile ./config/fingerprint.json);
        config = {
          "HDMI-1" = {
            enable = true;
            mode = "3840x2160";
            rate = "59.94";
            primary = false;
            position = "0x0";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
          "DP-4" = {
            enable = true;
            mode = "2560x1440";
            rate = "143.97";
            primary = true;
            position = "3840x720";
            scale = {
              x = 1.0;
              y = 1.0;
            };
            rotate = "normal";
          };
        };
      };
    };
    hooks = {
      postswitch = {
        "notify-polybar" = toString (
          pkgs.writeShellScript "notify-polybar" ''
            ${pkgs.systemd}/bin/systemctl --user restart polybar
          ''
        );
        "notify-bspwm" = toString (
          pkgs.writeShellScript "notify-bspwm" ''
            sleep 2
            ${pkgs.bspwm}/bin/bspc monitor HDMI-1 -d 4 5 6
            ${pkgs.bspwm}/bin/bspc monitor DP-4 -d 1 2 3
            ${pkgs.bspwm}/bin/bspc wm -r
          ''
        );
      };
    };

  };

  systemd.services.autorandr = {
    wantedBy = [ "graphical-session.target" ];
    # partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.autorandr}/bin/autorandr --change --default default";
    };
  };
  imports = [
    # (Dell Inc. 32"): 3840x2160 @ 60 Hz in 32″ [External]
    # Intel(R) Core(TM) i9-9900KS (16) @ 5.00 GHz
    # NVIDIA GeForce GTX 1080 Ti [Discrete]
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-hidpi
    ../../../modules/nixos/openrgb.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
    ../shared.nix
    ./config/desktop.nix
  ];

  system.stateVersion = "24.11";

  # FIXME: Just like with Windows, 2 hours early, maybe BIOS?
  # services.automatic-timezoned.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.zsh.enable = true;

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  hardware.nvidia.open = false; # Disable open source

  # All custom options originate from the shared options
  #custom.openrgb.enable = true;

  # boot.initrd.kernelModules = [
  #   "nvidia"
  #   "i915"
  #   "nvidia_modeset"
  #   "nvidia_uvm"
  #   "nvidia_drm"
  # ];

  boot.loader = {
    systemd-boot.enable = false;
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
      gfxmodeEfi = "2560x1440";
      theme = "${hyperfluent-theme}/nixos";
      extraConfig = ''
        GRUB_DEFAULT=saved
        GRUB_SAVEDEFAULT=true
      '';
    };
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    interfaces."${mainInterface}".wakeOnLan.enable = true;
    useDHCP = false;
    dhcpcd.wait = "background";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
    };
  };

}
