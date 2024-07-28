{...}: {
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment = {
    persistence = {
      "/persist/laptop" = {directories = ["/var/cache/powertop"];};
    };
  };

  networking = {
    hostId = "f7c80e5b";
    hostName = "laptop";
  };
}
