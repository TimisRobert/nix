{ inputs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
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
}
