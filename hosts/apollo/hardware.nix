# NVIDIA hardware, boot, and container runtime for apollo.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [
    "video=DP-4:2560x1440@143.97"
    "video=DP-0:d"
    "nvidia-drm.modeset=1"
    "nvidia.modeset=1"
  ];

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.sessionVariables = {
    "LIBGL_DEBUG" = "verbose";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
}
