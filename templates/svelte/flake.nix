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
        default = pkgs.buildNpmPackage {
          name = "svelte";

          buildInputs = [pkgs.nodejs];

          src = ./.;
          npmDepsHash = "sha256-G95p/0ybx+ae5ROQ/R8X4AnDS1rABZYOkHIra5b/l9s=";

          installPhase = ''
            mkdir $out
            npm run build
            cp package.json $out
            cp -r node_modules $out
            cp -r build/. $out
          '';
        };
      in {
        packages.default = {inherit default;};

        devsenv.shells.default = {
          packages = [
            pkgs.nodejs_18
            pkgs.nodePackages.pnpm
          ];

          scripts.codegen.exec = "pnpm run codegen";
          services.postgres.enable = true;

          processes.svelte.command = "pnpm run dev";
        };
      };
    };
}
