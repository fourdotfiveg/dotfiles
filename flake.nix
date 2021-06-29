{
  description = "Baba's dotfiles";

  inputs = {
    nix.url = "github:nixos/nix";
    nix.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/master";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    flow.url = "path:../flow";

    # Emacs
    emacs.url = "github:nix-community/emacs-overlay";
    doom-emacs = {
      url = "github:hlissner/doom-emacs/develop";
      flake = false;
    };
    # FIXME: does not work for now
    # nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
    # nix-doom-emacs.inputs.doom-emacs.follows = "doom-emacs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
    let
      configuration = { config, pkgs, ... }: {
        home-manager.useUserPackages = true;

        nix = {
          binaryCaches = [
            "https://cache.nixos.org"
            "https://cache.ngi0.nixos.org/"
            "https://nix-community.cachix.org"
            "https://babariviere.cachix.org"
          ];
          binaryCachePublicKeys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "babariviere.cachix.org-1:igoOZJyEAhWg3Rbavjim3yyDj7nIkGYe5327+G0diFw="
          ];
          extraOptions = ''
            experimental-features = nix-command flakes ca-derivations ca-references
          '';
          gc = {
            automatic = true;
            options = "-d --delete-older-than 7d";
          };
          package = pkgs.hiPrio pkgs.nixUnstable;
          registry = {
            nixpkgs.flake = nixpkgs;
            dotfiles = {
              from = {
                id = "dotfiles";
                type = "indirect";
              };
              to = {
                type = "path";
                # HACK(babariviere): to ensure that it exists, create an option and make it clone automatically if the path doesn't exist
                path =
                  "${config.user.home}/src/github.com/babariviere/dotfiles";
              };
            };
          };
          trustedUsers = [ config.user.name ];
          sandboxPaths = [
            "/System/Library/Frameworks"
            "/System/Library/PrivateFrameworks"
          ];
          useSandbox = "relaxed";
        };

        nixpkgs = {
          overlays = let
            pythonOverride = super: python-self: python-super: {
              # https://github.com/NixOS/nixpkgs/issues/128266
              pycairo = python-super.pycairo.overrideAttrs (attrs: {
                doCheck = false;
                doInstallCheck = false;
                nativeBuildInputs =
                  builtins.filter (drv: drv.name != "pytest-check-hook")
                  attrs.nativeBuildInputs;
              });
            };
            pythonOverlay = self: super: {
              python = super.python.override {
                packageOverrides = pythonOverride super;
              };
              python3 = super.python3.override {
                packageOverrides = pythonOverride super;
              };
              python38 = super.python38.override {
                packageOverrides = pythonOverride super;
              };
            };
          in [
            inputs.neovim-nightly.overlay
            inputs.emacs.overlay
            pythonOverlay
            self.overlay
          ];

          # FIXME: https://github.com/NixOS/nix/issues/4903
          # config.contentAddressedByDefault = true;
        };

        services.nix-daemon.enable = true;
      };

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { lib = self; }; });

      modules = lib.my.findModulesRec ./modules;
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake ./modules/examples#darwinConfigurations.mac-fewlines.system \
      #       --override-input darwin .
      darwinConfigurations."ochatt" = darwin.lib.darwinSystem {
        modules = [ configuration home-manager.darwinModules.home-manager ]
          ++ modules ++ [ ./hosts/ochatt.nix ];
        specialArgs = { inherit inputs lib; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."ochatt".pkgs;

      lib = lib.my;

      overlay = import ./pkgs;

      packages.x86_64-darwin = let
        pkgs = import nixpkgs {
          system = "x86_64-darwin";
          overlays = [ inputs.emacs.overlay ];
        };
      in {
        emacsOsx = pkgs.callPackage ./pkgs/emacs { };
        lima = pkgs.callPackage ./pkgs/lima { };
      };
    };
}
