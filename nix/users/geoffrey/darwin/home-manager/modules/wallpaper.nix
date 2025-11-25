{
  config,
  lib,
  pkgs,
  ...
}:

let
  base16 = config.colorScheme.palette;
  wallpaperGenerator =
    import ../../../../../modules/shared/assets/wallpaper/nixos-wallpaper-generator.nix
      { inherit lib pkgs; };
  generatedWallpaper = wallpaperGenerator { base16theme = base16; };

  # Script to convert SVG to PNG and set wallpaper
  # Temporarily disabled due to writeShellScript using deprecated substituteAll
  # setWallpaperScript = pkgs.writeShellScript "set-wallpaper" ''
  #   # Convert SVG to PNG with high density using magick command
  #   ${pkgs.imagemagick}/bin/magick "${generatedWallpaper}" -density 300 /tmp/wallpaper.png
  #
  #   # Set the converted PNG as wallpaper
  #   /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/tmp/wallpaper.png"'
  # '';
in
{
  # Temporarily disabled due to writeShellScript using deprecated substituteAll
  # home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   $DRY_RUN_CMD ${setWallpaperScript}
  # '';

  # Ensure ImageMagick is available
  home.packages = [ pkgs.imagemagick ];
}
