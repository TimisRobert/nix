{
  pkgs,
  config,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  hardware = {
    graphics = {
      extraPackages = [pkgs.amdvlk];
      extraPackages32 = [pkgs.driversi686Linux.amdvlk];
    };
    keyboard.qmk.enable = true;
  };

  networking = {
    hostId = "d5a63149";
    hostName = "desktop";
  };
}
