{
  pkgs,
  config,
  lib,
  ...
}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
    gamemode.enable = true;
  };

  boot.initrd.kernelModules = ["nvidia" "nct6683"];

  hardware = {
    keyboard.qmk.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;
    };
  };

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
    services.k3s.wantedBy = lib.mkForce [];
  };

  environment = {
    etc = {
      rancher.source = "/persist/etc/rancher/";
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = ["--write-kubeconfig-mode 644"];
    };
    xserver.videoDrivers = ["nvidia"];
  };
}
