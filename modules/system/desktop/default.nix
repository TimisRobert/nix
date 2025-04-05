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
    keyboard.qmk.enable = true;
  };

  networking = {
    hostId = "d5a63149";
    hostName = "desktop";
    firewall.interfaces.incusbr0.allowedTCPPorts = [53 67];
    firewall.interfaces.incusbr0.allowedUDPPorts = [53 67];
  };

  virtualisation.incus = {
    package = pkgs.incus;
    enable = true;
    preseed = {
      networks = [
        {
          config = {
            "ipv4.address" = "10.0.100.1/24";
            "ipv4.nat" = "true";
          };
          name = "incusbr0";
          type = "bridge";
        }
      ];
      profiles = [
        {
          devices = {
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              size = "35GiB";
              type = "disk";
            };
          };
          name = "default";
        }
      ];
      storage_pools = [
        {
          config = {
            source = "zpool/incus";
          };
          driver = "zfs";
          name = "default";
        }
      ];
    };
  };

  users.users.rob.extraGroups = ["incus-admin"];

  environment = {
    persistence = {
      "/persist" = {
        directories = ["/var/lib/incus"];
      };
    };
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
