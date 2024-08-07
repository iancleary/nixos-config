{ config, lib, pkgs, ... }:

let
  fontName = config.myHome.gnome.font.name;
  fontSize = config.myHome.gnome.font.size;
in
{
  config = lib.mkIf config.myHome.gnome.enable {
    programs.alacritty = {
      enable = false; # cursor doesn't show up (2024-04-05...maybe fixed now?)
      package = pkgs.unstable.alacritty;
      settings = {
        env.TERM = "alacritty";

        window = {
          padding = { x = 6; y = 6; };
          opacity = 0.90;
        };
        cursor = {
          thickness = 0.1;
        };
        font = {
          normal = {
            family = fontName;
            style = "Regular";
          };
          bold = {
            family = fontName;
            style = "Bold";
          };
          italic = {
            family = fontName;
            style = "Italic";
          };
          bold_italic = {
            family = fontName;
            style = "Bold Italic";
          };
          size = fontSize;
        };
        colors = {
          inherit (config.myHome.colors) primary cursor normal bright;
        };
      };
    };
  };
}
