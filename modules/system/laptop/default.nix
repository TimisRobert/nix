{ inputs, config, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = let age = config.age; in { inherit inputs age; };
    users.rob = import ../../home/laptop;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment = {
    persistence = {
      "/nix/persist/laptop" = { directories = [ "/var/cache/powertop" ]; };
    };
  };

  systemd.network = {
    networks = {
      "20-wg" = {
        matchConfig.Name = "wg0";
        networkConfig = {
          Address = [ "10.0.0.2/32" ];
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
