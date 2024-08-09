{ config, inputs, lib, ... }:

let
  cfg = config.myHome;
in
{
  options = {
    myHome = {
      gnome = with lib; {
        enable = mkEnableOption "gnome";
      };

      kde = with lib; {
        enable = mkEnableOption "kde";
      };

      hyprland = with lib; {
        enable = mkEnableOption "hyprland";
      };
    };
  };

  imports = [
    ./colors.nix
    ./gnome
    ./hyprland
    ./nextcloud-autosync
    ./non-nixos.nix
    inputs.terminal-config.homeManagerModules.default
  ];
}
