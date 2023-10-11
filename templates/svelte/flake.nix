{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ moduleWithSystem, ... }: {
      imports = [ inputs.devshell.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { config, pkgs, ... }:
        let
          default = pkgs.buildNpmPackage {
            name = "svelte";

            buildInputs = [ pkgs.nodejs ];

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

        in
        {
          packages.default = { inherit default; };

          devshells.default = {
            packages = [
              pkgs.postgresql
              pkgs.nodejs_18
            ];

            env = [
              {
                name = "PGDATA";
                eval = "$PRJ_ROOT/.db";
              }
              {
                name = "DATABASE_URL";
                value = "postgres:///postgres";
              }
            ];

            commands = [{
              name = "codegen";
              help = "generate kysely types";
              command = "npm run codegen";
            }];

            serviceGroups = {
              webserver = {
                services.svelte.command = "npm run dev";
                services.postgres.command =
                  "postgres -c unix_socket_directories=$PGDATA";
              };
            };

            devshell.startup.setup_database.text = ''
              if [[ ! -d "$PGDATA" ]]; then
                mkdir -p $PGDATA
                initdb -U postgres
              fi
            '';
          };
        };
    });
}
