{inputs, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.rob = import ../../home/desktop;
  };

  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR nobody@example.com
    '';
  };
}
