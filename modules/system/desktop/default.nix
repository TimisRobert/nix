{inputs, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.rob = import ../../home/desktop;
  };

  networking.hostId = "6a42465f";
}
