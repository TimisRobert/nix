{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs @ { flake-parts
    , nixpkgs
    , nix2container
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.system.flakeExposed;
      imports = [ inputs.devenv.flakeModule ];

      perSystem =
        { config
        , pkgs
        , lib
        , inputs'
        , ...
        }:
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

            tailwindcss =
              pkgs.nodePackages.tailwindcss.overrideAttrs
                (_oldAttrs: {
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

          devenv.shells.default = {
            packages = [
              pkgs.inotify-tools
              pkgs.elixir
            ];

            services.postgres.enable = true;
            processes .phoenix.exec = "mix setup && mix phx.server";
          };
        };
    };
}
