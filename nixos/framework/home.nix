{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  myHome = {
    gnome.enable = false;
    kde.enable = false;
    hyprland.enable = true;
    nextcloud-autosync = {
      enable = true;
      folder = "${config.home.homeDirectory}/Nextcloud/";
      server = "http://nextcloud.iancleary.me";
    };
  };

  myTerminal = {
    cli.personalGitEnable = true;
    tmux.enable = true;
    zsh.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };

  home.packages = with pkgs; [
    brave
    jellyfin-media-player
    protonup
    signal-desktop
    super-slicer-latest
  ];
}
