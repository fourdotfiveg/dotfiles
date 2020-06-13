{ config, lib, pkgs, ... }:

let
  dotfiles = config.dotfiles;
  cfg = dotfiles.shell.git;
in {
  options.dotfiles.shell.git = with lib; {
    enable = mkEnableOption "git";

    signingKey = mkOption {
      type = types.nullOr types.str;
      description = "signing key for commits";
      default = null;
    };

    extraConfig = mkOption {
      type = types.attrs;
      description = "extra config for git";
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        gitAndTools.gitFull
        git-crypt
        gitAndTools.hub
        gitAndTools.diff-so-fancy
        gitAndTools.gitflow
        github-cli
      ];

      shellAliases = {
        ga = "git add";
        gc = "git commit";
        gcm = "git commit -m";
        gp = "git push";
        gpl = "git pull --rebase --autostash";
        git = "hub";
      };
    };

    home-manager.users."${dotfiles.user}".programs.git = {
      enable = true;

      extraConfig = let inherit (pkgs.gitAndTools) delta;
      in {
        core.pager = "${delta}/bin/delta --theme='GitHub'";
        interactive.diffFilter = "${delta}/bin/delta --color-only";

        # Color defined by diff-so-fancy
        color = {
          ui = true;
          diff-highlight = {
            oldNormal = "red bold";
            oldHighlight = "red bold 52";
            newNormal = "green bold";
            newHighlight = "green bold 52";
          };
          diff = {
            meta = "11";
            frag = "magenta bold";
            commit = "yellow bold";
            old = "red bold";
            new = "green bold";
            whitespace = "red reverse";
          };
        };

        url = {
          "git@bitbucket.org:" = { insteadOf = "https://bitbucket.org"; };
          "git@github.com" = { insteadOf = "github"; };
        };

        diff.algorithm = "patience";
      } // cfg.extraConfig;
      signing = lib.mkIf (cfg.signingKey != null) {
        key = cfg.signingKey;
        signByDefault = true;
      };
      userEmail = dotfiles.email;
      userName = dotfiles.name;
    };
  };
}
