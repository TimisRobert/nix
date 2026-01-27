{config, ...}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode = {
      enable = true;
      settings.cpu.park_cores = "yes";
    };
  };

  boot.initrd.kernelModules = ["nvidia" "nct6683"];
  boot.kernelParams = ["nvidia.NVreg_EnableResizableBar=1"];

  hardware = {
    keyboard.qmk.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;
    };
    nvidia-container-toolkit.enable = true;
  };

  users.users.rob.extraGroups = ["gamemode"];

  networking = {
    hostId = "d5a63149";
    hostName = "desktop";
    firewall = {
      allowedTCPPorts = [6443 10250];
      allowedUDPPorts = [8472];
    };
  };

  systemd = {
    sleep.extraConfig = ''
      SuspendState=mem
    '';
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
  };
}
