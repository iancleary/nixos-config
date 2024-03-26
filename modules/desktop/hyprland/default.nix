# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, ... }:
let
  # Mixing unstable and stable channels
  # https://nixos.wiki/index.php?title=FAQ&oldid=3528#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgs-unstable = (import inputs.nixpkgs-unstable) {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
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

  # Install Flatpak
  services.flatpak.enable = true;

  # Gnome Keyring
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # swaylock
  # https://discourse.nixos.org/t/swaylock-wont-unlock/27275
  security.pam.services.swaylock = { };
  security.pam.services.swaylock.fprintAuth = false;

  services.blueman.enable = true;

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

  # xdg.portal = {
  #   enable = true;
  #   # extraPortals = with pkgs; [
  #   #   xdg-desktop-portal-hyprland
  #   # ];
  # };

  #  systemd.services.hyprland = {
  #   enable = true;
  #   description = "Hyprland";
  #   # script = "/run/current-system/sw/bin/ulauncher --hide-window";
  #   script = "agetty -o '-p -f -- \u' --noclear --autologin iancleary %I $TERM";
  #   serviceConfig = {
  #     StandardInput = "tty";
  #     TTYPath = "/dev/tty2";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #     Type = "idle";
  #   };
  #   aliases = [ "display-manager.service" ];
  #   documentation = [ "https://github.com/coastalwhite/lemurs" ];
  #   after = [ "sysinit.target" ];
  # };

  # Service to start
  # copied from https://discourse.nixos.org/t/ulauncher-and-the-debugging-journey/13141/5?u=iancleary
  # modified to use pkg-unstable instead of pkgs
  # names of wantedBy targets and after services are different for user services
  # launches with CTRL+SPACE
  # systemd.services.lemurs = {
  #   enable = true;
  #   description = "Lemurs";
  #   # script = "/run/current-system/sw/bin/ulauncher --hide-window";
  #   script = "/run/current-system/sw/bin/lemurs";
  #   serviceConfig = {
  #     StandardInput = "tty";
  #     TTYPath = "/dev/tty2";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #     Type = "idle";
  #   };
  #   aliases = [ "display-manager.service" ];
  #   documentation = [ "https://github.com/coastalwhite/lemurs" ];
  #   after = [ "getty.target" ];
  # };



  # systemd.user.services.hyprland = {
  #   enable = true;
  #   description = "Start Hyprland";
  #   # script = "/run/current-system/sw/bin/ulauncher --hide-window";
  #   script = "/run/current-system/sw/bin/Hyprland --config /home/iancleary/.config/hypr/hyprland.conf";

  #   documentation = [ "https://github.com/hyperwm/Hyprland" ];
  #   wantedBy = [ "default.target" ];
  #   after = [ "default.target" ];
  # };
}
