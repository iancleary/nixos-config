{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.gnome;
  profileUUID = "9e6bced8-89d4-4c52-aead-bbd59cbaad09";
  inherit (config.myHome) colors;
in
{

  imports = [ ./terminal.nix ];
  options.myHome.gnome = with lib; {
    wallpaper = mkOption {
      type = types.package;
      default = pkgs.landscapeWallpaper;
    };
    avatar = mkOption {
      type = types.package;
      default = pkgs.avatarPicture;
    };
    font = {
      package = mkOption {
        type = types.package;
        default = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
      };
      name = mkOption {
        type = types.str;
        default = "MesloLGS NF";
      };
      size = mkOption {
        type = types.int;
        default = 14;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [ cfg.font.package ];
    home.file.".face" = {
      source = cfg.avatar;
      target = ".face";
    };
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };
    };
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "gsconnect@andyholmes.github.io"
          "trayIconsReloaded@selfmade.pl"
        ];
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark";
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        screensaver = [ "<Shift><Control><Super>l" ];
      };
      "org/gnome/desktop/peripherals/trackball" = {
        scroll-wheel-emulation-button = 8;
        middle-click-emulation = true;
      };
      "org/gnome/desktop/sound".event-sounds = false;
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        monospace-font-name = cfg.font.name;
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file://${cfg.wallpaper}";
        picture-uri-dark = "file://${cfg.wallpaper}";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${cfg.wallpaper}";
      };
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/terminal/legacy" = {
        theme-variant = "dark";
      };
      "org/gnome/terminal/legacy/profiles:" = {
        default = profileUUID;
        list = [ profileUUID ];
      };
      "org/gnome/terminal/legacy/profiles:/:${profileUUID}" = {
        visible-name = "Oceanic Next";
        audible-bell = false;
        font = "${cfg.font.name} ${builtins.toString cfg.font.size}";
        use-system-font = false;
        use-theme-colors = false;
        default-size-columns = 120;
        default-size-rows = 60;
        background-color = colors.primary.background;
        foreground-color = colors.primary.foreground;
        bold-color = colors.primary.foreground;
        bold-color-same-as-fg = true;
        inherit (colors) palette;
        use-transparent-background = true;
        background-transparency-percent = 80;
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = "uint32 3000";
        night-light-schedule-automatic = false;
        night-light-schedule-from = 19.0;
        night-light-schedule-to = 6.0;
      };
      "org/gnome/mutter" = {
        workspaces-only-on-primary = true;
        dynamic-workspaces = true;
        edge-tiling = true;
      };
    };
  };
}

