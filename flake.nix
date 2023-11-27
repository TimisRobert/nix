{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    astronvim.url = "github:AstroNvim/AstroNvim";
    astronvim.flake = false;

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-parts
    , deploy-rs
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.devenv.flakeModule ];
      flake = {
        nixosConfigurations = {
          desktop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
              hostName = "desktop";
            };
            modules = [
              ./modules/system
              ./modules/system/desktop
              ./modules/hardware/desktop
            ];
          };
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
              hostName = "laptop";
            };
            modules = [
              ./modules/system
              ./modules/system/laptop
              ./modules/hardware/laptop
            ];
          };
          charon = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {
              inherit inputs;
              hostName = "charon";
            };
            modules = [ ./modules/system/charon ./modules/hardware/charon ];
          };
          site = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {
              inherit inputs;
              hostName = "site";
            };
            modules = [ ./modules/system/site ./modules/hardware/site ];
          };
        };

        deploy = {
          nodes = {
            charon = {
              hostname = "49.13.14.55";
              profiles.system = {
                sshUser = "root";
                path =
                  deploy-rs.lib.aarch64-linux.activate.nixos
                    self.nixosConfigurations.charon;
              };
            };
            site = {
              hostname = "49.13.78.96";
              profiles.system = {
                sshUser = "root";
                path =
                  deploy-rs.lib.aarch64-linux.activate.nixos
                    self.nixosConfigurations.site;
              };
            };
          };
          remoteBuild = true;
          fastConnection = true;
        };

        # checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

        templates = {
          phoenix = {
            path = ./templates/phoenix;
            description = "base phoenix liveview template";
            welcomeText = ''
              To install the rest run the following commands:
                - mix archive.install hex phx_new
                - mix phx.new .
            '';
          };
          elixir = {
            description = "base elixir template";
            path = ./templates/elixir;
          };
          zig = {
            description = "base zig template";
            path = ./templates/zig;
          };
          svelte = {
            path = ./templates/svelte;
            description = "base svelte template with tailwind";
            welcomeText = ''
              To install the rest run the following commands:
                - pnpm create svelte
                - pnpm i
            '';
          };
        };
      };

      perSystem =
        { inputs'
        , pkgs
        , ...
        }: {
          devenv.shells.default = {
            containers = pkgs.lib.mkForce { };
            packages = [
              inputs'.agenix.packages.default
              inputs'.deploy-rs.packages.default
            ];

            scripts = {
              deploy-charon.exec = "deploy .#charon -- --impure";
              deploy-site.exec = "deploy .#site -- --impure";
            };
          };
        };
    };
}
