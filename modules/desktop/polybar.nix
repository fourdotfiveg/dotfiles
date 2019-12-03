{ config, lib, pkgs, ... }:

with lib;
let
  dotfiles = config.dotfiles;
  cfg = dotfiles.desktop.polybar;
in {
  options.dotfiles.desktop.polybar = {
    battery = mkOption {
      type = types.str;
      description = "Battery name in /sys/class/power_supply.";
      default = "BAT0";
    };

    batteryAdapter = mkOption {
      type = types.str;
      description = "Battery name in /sys/class/power_supply.";
      default = "ADP0";
    };
  };

  config = lib.mkIf (dotfiles.desktop.enable && cfg.enable) {
    home-manager.users."${dotfiles.user}".services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = config.dotfiles.desktop.i3.enable;
        alsaSupport = true;
        pulseSupport = true;
      };
      extraConfig = builtins.readFile (pkgs.mutate <config/polybar/config>
        (dotfiles.colors // dotfiles.network // {
          inherit (cfg) battery batteryAdapter;
        }));
      script = "polybar top &";
    };

    environment.systemPackages = with pkgs; [ acpi ];

    fonts.fonts = with pkgs; [ siji ];
  };
}
