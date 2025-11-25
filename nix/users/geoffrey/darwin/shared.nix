{
  inputs,
  ...
}:
let
  name = "geoffrey";
in
{
  imports = [
    ../shared/unix.nix
    inputs.home-manager.darwinModules.home-manager
    # nix-homebrew is already imported in nix/modules/darwin/default.nix
    # inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.nixvim.nixDarwinModules.nixvim
  ];
  users.users.${name}.home = "/Users/${name}";
  system.keyboard.remapCapsLockToControl = true;
  system.keyboard.userKeyMapping = [
    # So C-Space works for tmux PREFIX
    {
      HIDKeyboardModifierMappingSrc = 30064771129; # Control-Space
      HIDKeyboardModifierMappingDst = 0; # Unbind
    }
  ];
}
