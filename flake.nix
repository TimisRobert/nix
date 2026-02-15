{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
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
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
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
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
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
