{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.rob = import ../../home/desktop;
  };

  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  # };

  networking.hostId = "d5a63149";
}
