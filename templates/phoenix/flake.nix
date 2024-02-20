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
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [inputs.devenv.flakeModule];

      perSystem = {
        pkgs,
        lib,
        config,
        ...
      }: let
        elixir = pkgs.beam.packages.erlangR26.elixir_1_16;
        elixir-ls = (pkgs.elixir-ls.override {inherit elixir;}).overrideAttrs {
          buildPhase = ''
            runHook preBuild
            mix do compile --no-deps-check, elixir_ls.release2
            runHook postBuild
          '';
        };
      in {
        devenv.shells.default = {
          packages = [
            pkgs.inotify-tools
            elixir
            elixir-ls
          ];

          services.postgres = {
            enable = true;
            package = pkgs.postgresql_16;
            initialDatabases = [{name = "";}];
            initialScript = ''
              create user postgres superuser;
            '';
            settings = {
              unix_socket_directories = lib.mkForce config.devenv.shells.default.env.PGDATA;
            };
          };

          processes = {
            phoenix.exec = "mix setup && mix phx.server";
          };
        };
      };
    };
}
