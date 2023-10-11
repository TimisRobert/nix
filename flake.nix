{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable/";
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

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    simple-nixos-mailserver.url =
      "gitlab:simple-nixos-mailserver/nixos-mailserver";
    simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, deploy-rs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" "x86_64-linux" ];
      imports = [ inputs.devshell.flakeModule ];
      flake = {
        nixosConfigurations = {
          desktop = nixpkgs.lib.nixosSystem {
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
          mail = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {
              inherit inputs;
              hostName = "mail";
            };
            modules = [ ./modules/system/mail ./modules/hardware/mail ];
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
                path = deploy-rs.lib.aarch64-linux.activate.nixos
                  self.nixosConfigurations.charon;
              };
            };
            mail = {
              hostname = "49.13.17.69";
              profiles.system = {
                sshUser = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos
                  self.nixosConfigurations.mail;
              };
            };
            site = {
              hostname = "49.13.78.96";
              profiles.system = {
                sshUser = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos
                  self.nixosConfigurations.site;
              };
            };
          };
          remoteBuild = true;
          fastConnection = true;
        };
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

      perSystem = { config, pkgs, lib, self', inputs', ... }: {
        devshells.default = {
          packages = [
            inputs'.agenix.packages.default
            inputs'.deploy-rs.packages.default
          ];
          commands = [
            {
              name = "deploy-charon";
              help = "deploy to node charon";
              command = "deploy .#charon";
            }
            {
              name = "deploy-mail";
              help = "deploy to node mail";
              command = "deploy .#mail";
            }
            {
              name = "deploy-site";
              help = "deploy to node site";
              command = "deploy .#site";
            }
          ];
        };
      };
    };
}
