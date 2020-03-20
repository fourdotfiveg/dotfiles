{ config, lib, pkgs, ... }:

let
  user = "bastien";
  unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
in {
  imports = [ ../. ../private/configuration.sollys.nix ../profiles/nvidia.nix ];

  dotfiles = {
    user = user;
    email = "bastien.riviere@easy.movie";
    theme = "one";
    network = {
      eth = "enp59s0";
      wlan = "wlo1";
    };
    desktop = {
      enable = true;
      bspwm.enable = true;
      # i3.enable = true;
      firefox.enable = true;
      polybar = {
        enable = true;
        battery = "BAT1";
        batteryAdapter = "ADP1";
      };
      termite.enable = true;
      compton.enable = false;
      dunst.enable = true;
      rofi.enable = true;
    };
    dev = {
      go.enable = true;
      php.enable = true;
      plantuml.enable = true;
      python.enable = true;
      rust.enable = true;
    };
    editors = {
      emacs.enable = true;
      neovim.enable = true;
    };
    shell = {
      direnv.enable = true;
      git = {
        enable = true;
        # signingKey = "C45AE603B0DB35266E0E1BBA7014714FCF05D20E";
      };
      zsh.enable = true;
    };
    services = {
      gpg.enable = true;
      keyring.enable = true;
      ssh.enable = true;
    };
    social = { slack.enable = true; };
    tools = {
      aws.enable = true;
      build.enable = true;
      docker = {
        enable = true;
        arion = true;
        compose = true;
      };
      devops.enable = true;
      insomnia.enable = true;
      light.enable = true;
      sql.enable = true;
    };
  };

  users.users."${user}" = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" ];
    hashedPassword =
      lib.removeSuffix "\n" (builtins.readFile ../private/bastien.passwd);
  };

  networking.hostName = "sollys";
  environment.variables = { HOSTNAME = "sollys"; };
}
