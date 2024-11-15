{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    nixpkgs,
    self,
    ...
  }:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.nixos-flake.flakeModule
      ];
      flake = {
        nixosConfigurations = {
          desktop = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              self.nixosModules.desktop
              self.nixosModules.home-manager
              {home-manager.users.rob.imports = [self.homeModules.desktop];}
            ];
          };
          laptop = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              self.nixosModules.laptop
              self.nixosModules.home-manager
              {home-manager.users.rob.imports = [self.homeModules.laptop];}
            ];
          };
        };

        nixosModules = {
          desktop.imports = [
            inputs.impermanence.nixosModules.impermanence
            inputs.microvm.nixosModules.host
            ./modules/system
            ./modules/system/desktop
            ./modules/hardware/desktop
          ];
          laptop.imports = [
            inputs.impermanence.nixosModules.impermanence
            ./modules/system
            ./modules/system/laptop
            ./modules/hardware/laptop
          ];
        };

        homeModules = {
          desktop.imports = [
            inputs.impermanence.nixosModules.home-manager.impermanence
            inputs.nix-index-database.hmModules.nix-index
            ./modules/home
            ./modules/home/desktop
          ];
          laptop.imports = [
            inputs.impermanence.nixosModules.home-manager.impermanence
            inputs.nix-index-database.hmModules.nix-index
            ./modules/home
            ./modules/home/laptop
          ];
        };
      };

      perSystem = {self', ...}: {
        packages.default = self'.packages.activate;
        nixos-flake.primary-inputs = ["nixpkgs" "home-manager"];
      };
    };
}
