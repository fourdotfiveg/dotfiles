{ config, lib, pkgs, ... }:

let
  dotfiles = config.dotfiles;
  cfg = dotfiles.desktop.dunst;
in {
  config = lib.mkIf (dotfiles.desktop.enable && cfg.enable) {
    home-manager.users."${dotfiles.user}".xdg.configFile."dunst/dunstrc".source =
      pkgs.mutate <config/dunst/dunstrc> (dotfiles.colors // {
        rofi = pkgs.rofi;
        browser = pkgs.firefox;
      });

    environment.systemPackages = [ pkgs.dunst ];
  };
}