{
  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    inputs@{ flake-parts, devenv-root, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      {
        imports = [
          inputs.devenv.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "i686-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        perSystem =
          {
            config,
            self',
            inputs',
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
              ];
            };
            packages.lrs_073a = pkgs.pkgsStatic.lrs_073a;
            packages.lrs_073a_mingw = pkgs.pkgsCross.mingwW64.lrs_073a;
            packages.lrs_071b = pkgs.pkgsStatic.lrs_071b;
            packages.lrs_071b_mingw = pkgs.pkgsCross.mingwW64.lrs_071b;
            packages.lrs = config.packages.lrs_071b;
            packages.lrs_mingw = config.packages.lrs_071b_mingw;
            packages.lrs_071b_darwin_x86 =
              (import inputs.nixpkgs {
                system = "x86_64-darwin";
                overlays = [ self.overlays.default ];
              }).pkgsStatic.lrs_071b;

            devenv.shells.default = {

              imports = [
                ./vendor/python
              ];

              packages = with pkgs; [
                config.packages.lrs
                nixfmt-rfc-style
                nil
              ];

            };

          };
        flake = {
          # The usual flake attributes can be defined here, including system-
          # agnostic ones like nixosModule and system-enumerating ones, although
          # those are more easily expressed in perSystem.
          overlays.default = import ./vendor/lrslib;
        };
      }
    );
}
