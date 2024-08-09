{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.gnome;
in
{
  options.mySystem.gnome = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        firefox
        wl-clipboard
        spotify
        warp-terminal
        gedit # changed to pkgs.gedit in 24.05
        gnome.gnome-tweaks
        gnome.sushi
        linssid
        angryipscanner
        todoist-electron
        xdg-desktop-portal-gnome
        gnomeExtensions.appindicator
        gnomeExtensions.gsconnect
        gnomeExtensions.tray-icons-reloaded
      ];
      variables = {
        NIXOS_OZONE_WL=1;
      };
      gnome.excludePackages = with pkgs.gnome; [
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        pkgs.gnome-console
        pkgs.gnome-connections
        pkgs.gnome-tour
        pkgs.yelp # yelp, gnome-help
        gnome-contacts
        gnome-maps
        gnome-music
        # gnome-weather
        totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ];
    };

    services = {
      xserver = {
        enable = true;
        # Configure keymap in X11
        xkb = {
          layout = "us";
          variant = "";
        };
        # enable GNOME
        displayManager.gdm = {
          enable = true;
          settings = {
            greeter.IncludeAll = true;
          };
          # https://github.com/NixOS/nixpkgs/issues/206630#issuecomment-1518696676
          # # resolves nextcloud-client install working
          # importedVariables = [
          #   "XDG_SESSION_TYPE"
          #   "XDG_CURRENT_DESKTOP"
          #   "XDG_SESSION_DESKTOP"
          # ];
        };
        desktopManager.gnome.enable = true;
        # Excluding some GNOME applications from the default install
        excludePackages = with pkgs; [
          xterm
        ];
      };
      udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Install Flatpak
      flatpak.enable = true;
    };

    programs = {
      gnome-terminal.enable = true;
      zsh.vteIntegration = true;
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    sound.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
      ];
    };

    systemd = {
      # https://discourse.nixos.org/t/how-to-disable-networkmanager-wait-online-service-in-the-configuration-file/19963/2
      services.NetworkManager-wait-online.enable = false;

      network.wait-online = {
        ignoredInterfaces = [
          "lo"
        ];
        # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1273814285
        anyInterface = true;
      };
    };
  };
}
