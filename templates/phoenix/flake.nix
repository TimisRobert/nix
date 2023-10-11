{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, nixpkgs, nix2container, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" "x86_64-linux" ];
      imports = [ inputs.devshell.flakeModule ];

      perSystem = { config, pkgs, lib, self', inputs', ... }:
        let
          pname = "app";
          beamPkgs = with pkgs.beam_minimal;
            packagesWith
              (interpreters.erlang.override { installTargets = [ "install" ]; });
          erlang = beamPkgs.erlang;
          elixir = beamPkgs.elixir;

          fetchMixDeps = beamPkgs.fetchMixDeps.override { inherit elixir; };
          mixRelease = beamPkgs.mixRelease.override {
            inherit elixir erlang fetchMixDeps;
          };
          buildImage = inputs'.nix2container.packages.nix2container.buildImage;

          default = mixRelease rec {
            inherit pname;
            src = ./.;
            version = "0.0.1";

            tailwindcss = pkgs.nodePackages.tailwindcss.overrideAttrs
              (oldAttrs: {
                plugins = [ pkgs.nodePackages."@tailwindcss/forms" ];
              });

            mixFodDeps = fetchMixDeps {
              inherit pname version src;
              sha256 = lib.fakeHash;
            };

            postBuild = ''
              ln -s ${pkgs.esbuild}/bin/esbuild _build/esbuild-linux-x64
              ln -s ${tailwindcss}/bin/tailwind _build/tailwind-linux-x64
              ln -s ${mixFodDeps} deps

              mix assets.deploy
              mix phx.digest
            '';
          };

          container = buildImage {
            name = pname;
            copyToRoot = pkgs.buildEnv {
              name = "root";
              paths = [ pkgs.busybox ];
              pathsToLink = [ "/bin" ];
            };
            config = { entrypoint = [ "${default}/bin/${pname}" "start" ]; };
          };

        in
        {
          packages = { inherit default container; };

          devshells.default = {
            packages = [
              pkgs.postgresql
              pkgs.inotify-tools
              pkgs.elixir
            ];

            env = [{
              name = "PGDATA";
              eval = "$PRJ_DATA_DIR/.db";
            }];

            serviceGroups = {
              webserver = {
                services.phoenix.command = "mix setup && mix phx.server";
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
    };
}
