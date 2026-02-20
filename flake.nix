{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    flake-parts.url = "https://flakehub.com/f/hercules-ci/flake-parts/0.1";

    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "https://flakehub.com/f/nix-community/stylix/0.1";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "https://flakehub.com/f/nix-community/disko/*";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs = inputs @ {nixpkgs, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      flake = {
        nixosConfigurations = {
          desktop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
              system = "x86_64-linux";
            };
            modules = [
              inputs.determinate.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.disko.nixosModules.disko
              ./modules/disko/desktop.nix
              ./modules/system
              ./modules/system/desktop
              ./modules/hardware/desktop
              {
                home-manager = {
                  extraSpecialArgs = {
                    inherit inputs;
                    system = "x86_64-linux";
                  };
                  useGlobalPkgs = true;
                  backupFileExtension = "backup";
                  users.rob = import ./modules/home/desktop;
                };
              }
            ];
          };
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
              system = "x86_64-linux";
            };
            modules = [
              inputs.determinate.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.disko.nixosModules.disko
              ./modules/disko/laptop.nix
              ./modules/system
              ./modules/system/laptop
              ./modules/hardware/laptop
              {
                home-manager = {
                  extraSpecialArgs = {
                    inherit inputs;
                    system = "x86_64-linux";
                  };
                  useGlobalPkgs = true;
                  backupFileExtension = "backup";
                  users.rob = import ./modules/home/laptop;
                };
              }
            ];
          };
        };
      };
    };
}
