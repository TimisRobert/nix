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
        devenvEnv = config.devenv.shells.default.env;
      in {
        devenv.shells.default = {
          env.MIX_HOME = "${devenvEnv.DEVENV_STATE}/.mix";

          packages = [
            elixir
            pkgs.inotify-tools
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
