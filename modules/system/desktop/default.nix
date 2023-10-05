{ inputs, pkgs, config, ... }:
let proton-ge = pkgs.callPackage ../../../pkgs/proton-ge.nix { };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = let age = config.age; in { inherit inputs age; };
    users.rob = import ../../home/desktop;
  };

  environment.variables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = proton-ge;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  systemd.network = {
    networks = {
      "20-wg" = {
        matchConfig.Name = "wg0";
        networkConfig = {
          Address = [ "10.0.0.3/32" ];
        };
        routes = [{
          routeConfig.Gateway = "10.0.0.1";
          routeConfig.Destination = "10.0.0.0/24";
          routeConfig.GatewayOnLink = true;
        }];
        DHCP = "no";
      };
    };
  };
}
