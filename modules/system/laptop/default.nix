{...}: {
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment = {
    # persistence = {
    #   "/persist/laptop" = {directories = ["/var/cache/powertop"];};
    # };
  };

  networking.hostName = "laptop";
}
