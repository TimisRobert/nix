{ inputs
, pkgs
, ...
}:
let
  proton-ge = pkgs.callPackage ../../../pkgs/proton-ge.nix { };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.rob = import ../../home/desktop;
  };

  environment.variables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = proton-ge;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
