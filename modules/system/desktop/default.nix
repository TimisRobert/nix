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

  services.zrepl = {
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
            interval = "30m";
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
}
