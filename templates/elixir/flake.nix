{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lexical.url = "github:lexical-lsp/lexical";
    lexical.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.devenv.flakeModule];
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {pkgs, ...}: let
        devenvEnv = config.devenv.shells.default.env;
      in {
        devenv.shells.default = {
          env.MIX_HOME = "${devenvEnv.DEVENV_STATE}/.mix";

          packages = [
            inputs'.lexical.packages.default
            pkgs.beam.packages.erlangR26.elixir_1_16
          ];
        };
      };
    };
}
