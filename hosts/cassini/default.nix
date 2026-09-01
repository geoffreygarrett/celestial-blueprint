{
  lib,
  pkgs,
  inputs,
  keys,
  ...
}:

let
  extraAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Uy9fE/YF8/puhUOwOcHKqDzDW75zt9DndypPEhQaG geoffrey@pioneer"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5fIudzRgRdB5m1Mh82hn1q239LT5UVRchin/CkdUuX geoffrey@voyager"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+T8WzvjnAsfpF+J2SMwt/L7XDR9XUYtGdTf6MitHID builder@localhost"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nix/modules/nixos/openssh.nix
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.dell-xps-15-9560
    inputs.nixos-hardware.nixosModules.dell-xps-15-9560-intel
    # Intel-only for now: better battery, no PRIME bus-ID risk, clean Wayland.
    # Re-enable when CUDA/dGPU is needed (and set hardware.nvidia.prime bus IDs).
    # inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "auto";
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  hardware.enableRedistributableFirmware = true;

  # No disk swap is configured; zram keeps parallel builds from OOMing.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    earlySetup = true;
  };

  networking = {
    hostName = "cassini";
    networkmanager.enable = true;
  };

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";

  nix.settings = {
    trusted-users = [
      "root"
      "geoffrey"
    ];
    extra-platforms = [ "aarch64-linux" ];
    system-features = [
      "benchmark"
      "big-parallel"
      "kvm"
      "nixos-test"
    ];
    trusted-public-keys = [
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA="
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.geoffrey = {
    isNormalUser = true;
    description = "Geoffrey Garrett";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "disk"
    ];
    openssh.authorizedKeys.keys = keys ++ extraAuthorizedKeys;
  };

  users.users.root.openssh.authorizedKeys.keys = keys;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  services.openssh = {
    enable = true;
    settings.UseDns = lib.mkForce false;
  };

  system.stateVersion = "24.05";
}
