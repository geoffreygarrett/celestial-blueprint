{
  self,
  lib,
  pkgs,
  config,
  home-manager,
  user,
  keys,
  inputs,
  ...
}:
{

  local.dock = {
    enable = true;
    entries = [
      # Development tools
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "/Applications/Firefox.app/"; }
      { path = "/Applications/Obsidian.app/"; }
      { path = "/Applications/Mendeley Reference Manager.app/"; }
      {
        path = "${config.users.users.${user}.home}/Projects";
        section = "others";
        options = "--view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--view fan --display stack";
      }
      # Temporarily disabled due to writeShellScriptBin using deprecated substituteAll
      # {
      #   path = "${pkgs.writeShellScriptBin "update-system" ''
      #     ${pkgs.alacritty}/bin/alacritty -e bash -c 'cd ~/.dotfiles && nix flake update && nix run ".#switch"'
      #   ''}/bin/update-system";
      #   section = "others";
      # }
    ];

    #      { path = "${pkgs.docker}/Applications/Docker.app/"; }
    #
    #      # Browsers
    #      { path = "/Applications/Google Chrome.app/"; }
    #
    #      # Communication
    #      { path = "/System/Applications/Messages.app/"; }
    #      { path = "/Applications/Zoom.app/"; }
    #
    #      # Productivity
    #      { path = "/System/Applications/Reminders.app/"; }
    #
    #      # Utils
    #      { path = "/Applications/1Password.app/"; }
    #      { path = "/Applications/TablePlus.app/"; }
    #
  };

  home-manager = {
    useGlobalPkgs = true;
    # backupFileExtension is set in nix/users/geoffrey/shared/unix.nix
    sharedModules = [
inputs.nixvim.homeModules.nixvim inputs.sops-nix.homeModules.sops

      ../../packages/shared/shell-aliases
    ];
    users.${user} =
      {
        self,
        config,
        pkgs,
        inputs,
        ...
      }:
      {
        imports = [
          ../shared/aliases.nix
          ../shared/secrets.nix
          # ../shared/programs
          # Import user's home-manager configuration
          ../../users/geoffrey/home-manager/shared.nix
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages { };
          stateVersion = "23.11";

          # Disable fonts module to avoid apple_sdk_11_0 error
          # The fonts module in nix-darwin references darwin.apple_sdk_11_0 which has been removed
          # We disable it by not setting the file at all, which prevents the onChange script from being generated

          # Set up LIBRARY_PATH and CPATH for Rust linking on macOS
          # This ensures libiconv can be found when using cargo install
          # Note: Removed darwin.apple_sdk.frameworks references to avoid apple_sdk_11_0 error
          sessionVariables = {
            LIBRARY_PATH = lib.makeLibraryPath [
pkgs.libiconv

            ];
            CPATH = lib.makeSearchPath "include" [
pkgs.libiconv.dev

            ];
          };

          #          sessionVariables = {
          #            EDITOR = "nvim";
          #            VISUAL = "nvim";
          #            PAGER = "less";
          #            LESS = "-R";
          #            LESSOPEN = "| $(which lesspipe.sh) %s";
          #            LESSCLOSE = "kill %s";
          #            LESS_TERMCAP_mb = "\e[1;31m";
          #            LESS_TERMCAP_md = "\e[1;31m";
          #            LESS_TERMCAP_me = "\e[0m";
          #            LESS_TERMCAP_se = "\e[0m";
          #            LESS_TERMCAP_so = "\e[1;44;33m";
          #            LESS_TERMCAP_ue = "\e[0m";
          #            LESS_TERMCAP_us = "\e[1;32m";
          #          };
          #                    sessionPath = [
          #                        "$HOME/.cargo/bin"
          #                          "$HOME/.local/bin"
          #                      ];
        };
      };
    extraSpecialArgs = {
      inherit user inputs self;
    };
  };

  # User configuration
  # Note: shell is defined in nix/users/geoffrey/shared/unix.nix
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    # shell = pkgs.zsh; # Defined in shared/unix.nix
    openssh.authorizedKeys.keys = keys;
  };

  # Homebrew configuration
  # Temporarily disabled until Homebrew is reinstalled
  # To re-enable: Install Homebrew first, then set enable = true
  homebrew = {
    enable = false;
    casks = pkgs.callPackage ./casks.nix { } ++ [
      # "nikitabobko/tap/aerospace"
    ];
    brews = [
      "nushell"
      "pinentry-mac"
      "qemu"
      "gsmartcontrol"
    ];
    masApps = {
      "tailscale" = 1475387142;
    };
  };
}
