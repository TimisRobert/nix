{config, pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        cpu.park_cores = "yes";
      };
    };
  };

  boot = {
    supportedFilesystems = ["zfs"];
    kernelParams = ["nvidia.NVreg_EnableResizableBar=1"];
    initrd = {
      kernelModules = ["nvidia" "nct6683"];
      systemd.services.rollback = {
        wantedBy = ["initrd.target"];
        after = ["zfs-import-zpool.service"];
        before = ["sysroot.mount"];
        path = [pkgs.zfs];
        description = "Rollback ZFS datasets";
        serviceConfig.Type = "oneshot";
        unitConfig.DefaultDependencies = "no";
        script = "zfs rollback -r zpool/root@blank";
      };
    };
  };

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
    zfs = {
      autoSnapshot.enable = true;
      autoScrub = {
        enable = true;
        interval = "14:00 Europe/Rome";
      };
      trim.enable = true;
    };
    pipewire.wireplumber.extraConfig.soloCastDefault = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "equals:alsa_input.usb-Kingston_HyperX_SoloCast-00.analog-stereo";
            }
          ];
          actions = {
            update-props = {
              "priority.session" = 1900;
            };
          };
        }
      ];
    };
  };
}
