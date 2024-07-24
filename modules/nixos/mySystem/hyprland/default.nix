{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.mySystem.hyprland;
in
{
  options.mySystem.hyprland = with lib; {
    enable = mkEnableOption "hyprland";
    packages = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    imports = [
      # custom package
      ./power-panel.nix
    ];
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # Optional, hint electron apps to use wayland:
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services = {
      # Gnome Keyring
      gnome.gnome-keyring.enable = true;
      polkit.enable = true;

      flatpak.enable = true;

      # Bluetooth
      blueman.enable = true;

    };
    # swaylock
    # https://discourse.nixos.org/t/swaylock-wont-unlock/27275
    security.pam.services.swaylock.fprintAuth = false;


    environment.systemPackages = with pkgs; [
      # xdg-desktop-portal-hyprland # display portal for hyprland, required
      hyprpaper # wallpaper utility
      hyprpicker # color picker
      wl-clipboard # allows copying to clipboard (for hyprpicker)
      kitty # terminal emulator
      waybar # wayland bar
      wofi # app launcher

      # waybar applets
      networkmanagerapplet # nm-applet --indicator &
      blueman # blueman-applet
      udiskie # removable media/disk mounting

      polkit_gnome # polkit agent for GNOME
      gnome.seahorse # keyring manager GUI
      gnome.nautilus # file manager

      playerctl # media player control
      brightnessctl # brightness control

      blueberry # bluetooth manager GUI
      networkmanager # network manager, including nmtui, a network manager TUI

      swaylock # screen locker

      xdg-utils # allow xdg-open to work

      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      # pkgs-unstable.lemurs # TUI Login manager (crashes on NixOS)
    ];

    # https://nixos.wiki/wiki/Greetd
    # tweaked for Hyprland
    # ...
    # launches swaylock with exec-once in home/hyprland/hyprland.conf
    # ...
    # single user and single window manager
    # my goal here is auto-login with authentication
    # so I can declare my user and environment (Hyprland) in this config
    # my goal is NOT to allow user selection or environment selection at the the login screen
    # (which a login manager provides beyond just the authentication check)
    # so I don't need a login manager
    # I just launch Hyprland as iancleary automatically, which starts swaylock (to authenticate)
    # I thought I needed a greeter, but I really don't
    # ...
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "iancleary";
        };
        default_session = initial_session;
      };
    };
  };
}
