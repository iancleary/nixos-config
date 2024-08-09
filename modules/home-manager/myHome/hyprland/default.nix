# home.nix
{ config, lib, ... }:
let
  cfg = config.myHome.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # hyprland configuration
    home.file = {
      ".config/hypr/hyprland.conf".source = ./hyprland.conf;
      ".config/hypr/hyprland.conf".target = ".config/hypr/hyprland.conf";

      # wallpaper configuration
      ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
      ".config/hypr/hyprpaper.conf".target = ".config/hypr/hyprpaper.conf";


      ".config/hypr/wallpaper-red.jpg".source = ./justinmaller-red-black-abstract.jpg;
      ".config/hypr/wallpaper-red.jpg".target = ".config/hypr/wallpaper-red.jpg";

      ".config/hypr/wallpaper-blue.jpg".source = ./justinmaller-blue-black-abstract.jpg;
      ".config/hypr/wallpaper-blue.jpg".target = ".config/hypr/wallpaper-blue.jpg";

      ".config/hypr/lock.png".source = ./linux_makes_journeys_to_mars_possible.png;
      ".config/hypr/lock.png".target = ".config/hypr/lock.png";

      ".config/hypr/wofi.css".source = ./wofi.css;
      ".config/hypr/wofi.css".target = ".config/hypr/wofi.css";
    };
  };
}
