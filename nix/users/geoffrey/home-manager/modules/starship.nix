{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  starshipInit = shell: ''
    ${config.programs.starship.package}/bin/starship init ${shell}
  '';
in
{
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${inputs.self}/dotfiles/starship/starship.toml");
  };

  programs.bash.initExtra = lib.mkIf (
    config.programs.bash.enable && config.programs.starship.enable
  ) ''eval "$(${starshipInit "bash"})"'';

  programs.zsh.initExtra = lib.mkIf (config.programs.zsh.enable && config.programs.starship.enable) ''
    # Initialize starship if available (defensive check to prevent shell errors)
    if [ -f "${config.programs.starship.package}/bin/starship" ]; then
      eval "$(${starshipInit "zsh"})" 2>/dev/null || true
    elif command -v starship >/dev/null 2>&1; then
      eval "$(starship init zsh)" 2>/dev/null || true
    fi
  '';
  programs.fish.interactiveShellInit = lib.mkIf (
    config.programs.fish.enable && config.programs.starship.enable
  ) "${starshipInit "fish"} | source";

  # Example for extending the configuration to nushell, if needed in the future.
  # programs.nushell.extraConfig = lib.mkIf (
  #   config.programs.nushell.enable && config.programs.starship.enable
  # ) "${starshipInit "nu"} | save -f ~/.cache/starship/init.nu; source ~/.cache/starship/init.nu";
}
