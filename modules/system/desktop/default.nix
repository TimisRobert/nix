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

  boot.kernelModules = ["amdgpu"];

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

  services = {
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
