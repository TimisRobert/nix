{
  pkgs,
  config,
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

  boot.initrd.kernelModules = ["nvidia"];
  # boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

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
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
    zrepl = {
      enable = true;
      settings = {
        jobs = [
          {
            name = "backuppool_sink";
            type = "sink";
            root_fs = "backuppool";
            recv = {
              placeholder = {
                encryption = "inherit";
              };
            };
            serve = {
              type = "local";
              listener_name = "backuppool_sink";
            };
          }
          {
            name = "push_to_drive";
            type = "push";
            send = {
              encrypted = false;
            };
            connect = {
              type = "local";
              listener_name = "backuppool_sink";
              client_identity = config.networking.hostName;
            };
            filesystems = {
              "zpool/projects" = true;
              "zpool/documents" = true;
            };
            replication = {
              protection = {
                initial = "guarantee_resumability";
                incremental = "guarantee_incremental";
              };
            };
            snapshotting = {
              type = "manual";
            };
            pruning = {
              keep_sender = [
                {
                  type = "regex";
                  regex = ".*";
                }
              ];
              keep_receiver = [
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 14x1d | 3x30d";
                  regex = "^zrepl_.*";
                }
              ];
            };
          }
          {
            name = "snapshot";
            type = "snap";
            filesystems = {
              "zpool/projects" = true;
              "zpool/documents" = true;
            };
            snapshotting = {
              type = "periodic";
              prefix = "zrepl_";
              interval = "10m";
              timestamp_format = "iso-8601";
            };
            pruning = {
              keep = [
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 14x1d | 3x30d";
                  regex = "^zrepl_.*";
                }
              ];
            };
          }
        ];
      };
    };
  };
}
