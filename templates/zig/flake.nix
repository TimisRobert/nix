{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig.url = "github:mitchellh/zig-overlay";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem =
        { config
        , pkgs
        , inputs'
        , ...
        }: {
          devshells.default = {
            packages = [
              inputs'.zig.packages.master
            ];
          };
        };
    };
}
