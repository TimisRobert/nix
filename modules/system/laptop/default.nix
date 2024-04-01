{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.rob = import ../../home/laptop;
  };

  networking.hostId = "f7c80e5b";

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment = {
    persistence = {
      "/persist/laptop" = {directories = ["/var/cache/powertop"];};
    };
  };
}
