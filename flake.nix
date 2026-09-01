{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

gateframe-context-manager = {
  url = "github:geoffreygarrett/gateframe-context-manager/feat/nix-packaging";
  inputs.nixpkgs.follows = "nixpkgs";
};

    # System Management
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Security
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS-specific
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nikitabobko-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    # Linux-specific
    nixgl = {
      url = "github:guibou/nixGL";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
    };

    # Nvidia
    jetpack-nixos = {
      url = "github:anduril/jetpack-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # CLI
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Browser
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    # Custom (path flake — lock with `nix flake lock --update-input nixus`)
    nixus = {
      url = "git+file:///Users/geoffrey/.dotfiles?dir=nixus&ref=develop";
      flake = true;
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      # url = "github:serokell/deploy-rs/pull/271/head"; # concurrent remote builds
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argon40-nix.url = "github:guusvanmeerveld/argon40-nix";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      pre-commit-hooks,
      treefmt-nix,
      nixgl,
      disko,
      nixvim,
      darwin,
      xremap-flake,
      nix-homebrew,
      rust-overlay,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      ...
    }@inputs:
    let
      systems.linux = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      systems.darwin = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      systems.supported = systems.linux ++ systems.darwin;

      lib =
        nixpkgs.lib
        // home-manager.lib
        // {
          isLinux = system: builtins.elem system systems.linux;
          isDarwin = system: builtins.elem system systems.darwin;
          forAllSystems = f: nixpkgs.lib.genAttrs systems.supported f;
          forAllDarwinSystems = f: nixpkgs.lib.genAttrs systems.darwin f;
          forAllLinuxSystems = f: nixpkgs.lib.genAttrs systems.linux f;
          readSSHKeys = path: (builtins.fromTOML (builtins.readFile path)).authorized_keys;
        };
      user = "geoffrey";
      keys = lib.readSSHKeys ./.nixus.toml;
      
      mkPkgsFor =
        system: extraConfig:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            allowInsecure = false;
            allowUnsupportedSystem = true;
            # Note: allowUnfreePredicate is not set - allowUnfree = true allows all unfree packages
            # This is needed for copilot.vim which is unfree
          }
          // extraConfig;
          overlays =
            let
              path = ./nix/overlays;
              overlayFiles =
                with builtins;
                filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
                  attrNames (readDir path)
                );
            in
            # Fix missing/removed packages - must be first to catch evaluation errors
            [
              (final: prev: {
                # nodejs-18_x has been removed, use nodejs_20 or nodejs_22
                nodejs-18_x = prev.nodejs_20 or prev.nodejs;
                # typstfmt has been removed - replace with typstyle
                # This must be done before nix-darwin's fonts module evaluates pkgs.typstfmt
                typstfmt = prev.typstyle;
                # Stub darwin.apple_sdk_11_0 to use current SDK (workaround for packages that still reference it)
                darwin = prev.darwin or {} // {
                  apple_sdk_11_0 = prev.darwin.apple_sdk or (throw "darwin.apple_sdk not available");
                };
              })
            ]
            # Fix missing packages on Darwin (Linux-only packages being evaluated)
            ++ lib.optional (lib.isDarwin system) (
              final: prev: {
                plasma5Packages = prev.plasma5Packages or {} // {
                  kdeconnect-kde = prev.stdenv.mkDerivation {
                    pname = "kdeconnect-kde-stub";
                    version = "0.0.0";
                    dontBuild = true;
                    installPhase = "mkdir -p $out";
                  };
                };
              }
            )
            ++ lib.optional (lib.isLinux system) nixgl.overlay
            ++ map (n: import (path + ("/" + n))) overlayFiles
            ++ [
              inputs.gateframe-context-manager.overlays.default
              # Only include nixus overlay if nixus input is available (path inputs can't be locked)
              (final: prev: {
                nixus = if builtins.pathExists ./nixus then self.packages.${system}.nixus else prev.nixus or null;
              })
              inputs.nixpkgs-firefox-darwin.overlay
            ];
        };
      pkgsFor = system: mkPkgsFor system { };
      treefmtEval = lib.forAllSystems (
        system: treefmt-nix.lib.evalModule (pkgsFor system) ./nix/formatter/default.nix
      );
      sharedDnsmasqConfig = {
        enable = true;
        # debugMode = true;
        hosts = {
          "apollo.nixus.net" = {
            addresses = [
              {
                ip = "100.125.219.65";
                type = "tailscale";
              }
              {
                ip = "192.168.68.129";
                type = "local";
              }
            ];
          };
          "curiosity.nixus.net" = {
            addresses = [
              {
                ip = "192.168.68.106";
                type = "local";
              }
            ];
          };
        };
        # extraConfig = ''
        #   log-queries
        #   log-facility=/var/log/dnsmasq.log
        # '';
        settings = {
          server = [
            "1.1.1.1" # Cloudflare primary
            "1.0.0.1" # Cloudflare secondary
            "9.9.9.9" # Quad9 primary
            "149.112.112.112" # Quad9 secondary
            "8.8.8.8" # Google primary
            "8.8.4.4" # Google secondary
          ];
          cache-size = 1000;
          no-resolv = true;
          dnssec-check-unsigned = true;
          domain-needed = true;
          bogus-priv = true;
          listen-address = "127.0.0.1";
        };
      };
      formatHosts =
        dnsSettings:
        lib.concatStringsSep "\n" (
          lib.flatten (
            lib.mapAttrsToList (
              hostname: entry: map (addr: "${addr.ip} ${hostname}") entry.addresses
            ) dnsSettings
          )
        );

      nixusDnsmasqModules = [
        inputs.nixus.nixosModules.dnsmasq
        { nixus.dnsmasq = sharedDnsmasqConfig; }
      ];

    in
    {

      ##############################
      # Packages Configuration
      ##############################
      packages = lib.forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          gateframe-context-manager = pkgs.gateframe-context-manager;

          nixus = import ./nix/apps/nixus {
            inherit
              system
              pkgs
              rust-overlay
lib

              ;
          };
          hosts = pkgs.writeShellScriptBin "hosts" (builtins.readFile ./scripts/print_hosts.sh);
          alacritty = pkgs.alacritty;
        }
      );

      ##############################
      # Apps Configuration
      ##############################
      apps = lib.forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          nixusApp = self.packages.${system}.nixus;
        in
        {
          default = {
            type = "app";
            program = "${nixusApp}/bin/nixus";
          };
          switch = {
            type = "app";
            program = "${pkgs.writeScriptBin "switch" (builtins.readFile ./nix/apps/switch.sh)}/bin/switch";
          };
          build = {
            type = "app";
            program = "${pkgs.writeScriptBin "build" (builtins.readFile ./nix/apps/build.sh)}/bin/build";
          };
          deploy = {
            type = "app";
            program = "${pkgs.writeScriptBin "deploy" (builtins.readFile ./nix/apps/deploy.sh)}/bin/deploy";
          };
          flash = {
            type = "app";
            program = "${import ./nix/apps/flash.nix { inherit pkgs; }}/bin/nixos-sd-flasher";
          };
          nixus = {
            type = "app";
            program = "${nixusApp}/bin/nixus";
          };
          sync = {
            type = "app";
            program = "${import ./nix/apps/sync.nix { inherit pkgs; }}/bin/sync";
          };
          check = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "run-checks" ''
              ${self.checks.${system}.pre-commit-check.shellHook}
              pre-commit run --all-files
            ''}/bin/run-checks";
          };
        }
      );

      ##############################
      # Darwin Configuration
      ##############################
      darwinConfigurations =
        let
          specialArgs = {
            inherit
              inputs
              self
              user
              keys
              ;
          };
          homeManagerModule = {
            home-manager.sharedModules = [
              ./nix/modules/shared/colors.nix
            ];
          };
          # nix-homebrew disabled - using nix-darwin's built-in homebrew module instead
          nixHomebrewModule = { };
        in
        {
          "artemis" = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            inherit specialArgs;
            pkgs = pkgsFor "aarch64-darwin";
            modules = [
              { networking.hostName = "artemis"; }
              # inputs.nixus.darwinModules.dnsmasq
              # { nixus.dnsmasq = sharedDnsmasqConfig; }
              ./hosts/artemis
              # nixHomebrewModule  # Disabled - using nix-darwin's homebrew module
# Disable home-manager fonts module to avoid apple_sdk_11_0 error
{
  home-manager.users.${user}.home.file."Library/Fonts/.home-manager-fonts-version" = lib.mkForce {
    text = "";
    onChange = "";
  };
}

            ];
          };
        };

      ##############################
      # Deploy Nodes :deploy
      ##############################
      deploy = {
        nodes =
          let
            commonSshOpts = [ ];
          in
          {
            "curiosity" = {
              # Jetson Orin Nano 8GB
              hostname = "curiosity.nixus.net";
              profiles.system = {
                sshUser = "${user}";
                user = "root";
                remoteBuild = true;
                magicRollback = false;
                sshOpts = commonSshOpts;
                confirmTimeout = 300;
                activationTimeout = 600;
                path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.curiosity;
              };
            };
            "cassini" = {
              hostname = "192.168.0.106";
              profiles.system = {
                sshUser = "${user}";
                user = "root";
                remoteBuild = true;
                magicRollback = false;
                sshOpts = commonSshOpts;
                confirmTimeout = 300;
                activationTimeout = 600;
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.cassini;
              };
            };
          };
      };

      ##############################
      # NixOS Configuration :nixos
      ##############################
      nixosConfigurations =
        let
          specialArgs = {
            inherit
              inputs
              self
              user
              keys
              ;
          };
          homeManagerModule = {
            home-manager = {
              sharedModules = [
                inputs.sops-nix.homeModules.sops
                inputs.nixvim.homeModules.nixvim
                inputs.gateframe-context-manager.homeManagerModules.default
                ./nix/packages/shared/shell-aliases
                ./nix/modules/shared/colors.nix
              ];
              useGlobalPkgs = true;
              extraSpecialArgs = specialArgs;
              users.${user} = import ./nix/modules/nixos/home-manager.nix;
            };
          };

        in
        {

          "apollo" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            pkgs = pkgsFor "x86_64-linux";
            modules = [
              ./hosts/apollo
              homeManagerModule
            ]
            ++ nixusDnsmasqModules;
          };

          "curiosity" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = mkPkgsFor "aarch64-linux" {
              cudaSupport = true;
              cudaCapabilities = [ "8.7" ];
            };
            modules = [
              ./hosts/curiosity/default.nix
              ./nix/users/geoffrey/nixos/desktop.nix
              homeManagerModule
            ]
            ++ nixusDnsmasqModules;
          };

          "cassini" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            pkgs = pkgsFor "x86_64-linux";
            modules = [
              ./hosts/cassini/default.nix
              # GNOME desktop. Swap for ./nix/users/geoffrey/nixos/desktop.nix
              # to go back to the bspwm/polybar/skhd setup, which is untouched.
              ./nix/users/geoffrey/nixos/gnome.nix
              homeManagerModule
            ]
            ++ nixusDnsmasqModules;
          };

          "installation-cd-minimal" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./hosts/_installers/installation-cd-minimal.nix
            ];
          };

          "rpi-4-bootstrap" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./hosts/_installers/rpi-4-bootstrap.nix
              { networking.hostName = lib.mkForce "rpi-4-bootstrap"; }
            ];
          };

          "rpi-3-bootstrap" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";
            pkgs = pkgsFor "aarch64-linux";
            modules = [
              ./hosts/_installers/rpi-3-bootstrap.nix
              { networking.hostName = lib.mkForce "rpi-3-bootstrap"; }
            ];
          };

        };

      # Inactive hosts preserved under hosts/_quarantine/

      ##############################
      # Home Configuration :home
      ##############################
      homeConfigurations = lib.forAllSystems (
        system:
        lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules =
            [
                  inputs.gateframe-context-manager.homeManagerModules.default

inputs.sops-nix.homeModules.sops inputs.nixvim.homeModules.nixvim

              ./nix/packages/shared/shell-aliases
            ]
            ++ lib.filter (m: m != null) [
              (if lib.isDarwin system then ./nix/modules/darwin/default.nix else null)
              (if lib.isLinux system then ./nix/modules/linux/default.nix else null)
            ];
          extraSpecialArgs = {
            inherit
              self
              inputs
              user
              ;
          };
        }
      );

      ##############################
      # Checks Configuration :checks
      ##############################
      checks =
        nixpkgs.lib.mapAttrs (name: config: config.activationPackage) self.homeConfigurations
        // lib.forAllSystems (system: {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # nixfmt-rfc-style.enable = true;
              # beautysh.enable = true;
              commitizen.enable = true;
            };
          };
        });

      ##############################
      # Formatter Configuration :formatter
      ##############################
      formatter = lib.forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      ##############################
      # Dev Shell Configuration :devShells
      ##############################
      devShells = lib.forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
        };
      });
    };
}
