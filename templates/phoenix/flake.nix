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
      }: {
        devenv.shells.default = {
          packages = [
            pkgs.inotify-tools
            pkgs.elixir
          ];

          services.postgres = {
            enable = true;
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
