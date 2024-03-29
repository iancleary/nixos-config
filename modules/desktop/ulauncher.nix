# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:
let
  # Mixing unstable and stable channels
  # https://nixos.wiki/index.php?title=FAQ&oldid=3528#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgs-unstable = (import inputs.nixpkgs-unstable) {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  environment.systemPackages = [
    pkgs-unstable.ulauncher
  ];

  # Service to start
  # copied from https://discourse.nixos.org/t/ulauncher-and-the-debugging-journey/13141/5?u=iancleary
  # modified to use pkg-unstable instead of pkgs
  # names of wantedBy targets and after services are different for user services
  # launches with CTRL+SPACE
  systemd.user.services.ulauncher = {
    enable = true;
    description = "Start Ulauncher";
    # script = "/run/current-system/sw/bin/ulauncher --hide-window";
    script = "${pkgs-unstable.ulauncher}bin/ulauncher --hide-window";

    documentation = [ "https://github.com/Ulauncher/Ulauncher/blob/f0905b9a9cabb342f9c29d0e9efd3ba4d0fa456e/contrib/systemd/ulauncher.service" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };
}
