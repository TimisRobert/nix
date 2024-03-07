{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
        elixir = pkgs.beam.packages.erlangR26.elixir_1_16;
        devenvEnv = config.devenv.shells.default.env;
      in {
        devenv.shells.default = {
          env.MIX_HOME = "${devenvEnv.DEVENV_STATE}/.mix";

          packages = [
            elixir
          ];
        };
      };
    };
}
