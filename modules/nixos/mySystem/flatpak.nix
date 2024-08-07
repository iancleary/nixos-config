{ config, lib, ... }:

let
  cfg = config.mySystem.flatpak;
in
{
  options.mySystem.flatpak = with lib; {
    enable = mkEnableOption "flatpak";
    packages = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    # https://github.com/gmodena/nix-flatpak?tab=readme-ov-file#updates
    update.auto = mkOption {
      type = types.attrs;
      default = {
        enable = true;
        onCalendar = "weekly";
      };
    };
    # enforce declarative installations
    uninstallUnmanaged = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = with cfg; {
      inherit packages uninstallUnmanaged;
      update.auto = update.auto;
    };
  };
}
