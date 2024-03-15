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
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [inputs.devenv.flakeModule];

      perSystem = {
        pkgs,
        lib,
        config,
        inputs',
        ...
      }: let
        devenvEnv = config.devenv.shells.default.env;
      in {
        devenv.shells.default = {
          env.MIX_HOME = "${devenvEnv.DEVENV_STATE}/.mix";

          packages = [
            inputs'.lexical.packages.default
            pkgs.beam.packages.erlangR26.elixir_1_16
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
