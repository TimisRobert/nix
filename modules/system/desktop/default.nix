{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.rob = import ../../home/desktop;
  };

  networking.hostId = "d5a63149";
}
