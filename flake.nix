{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    astronvim.url = "github:AstroNvim/AstroNvim";
    astronvim.flake = false;
  };

  outputs =
    inputs @ { nixpkgs
    , flake-parts
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ ];
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
    };
}
