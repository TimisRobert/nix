{config, pkgs, ...}: {
  programs = {
    dank-material-shell.greeter.compositor.customConfig = ''
      hotkey-overlay {
        skip-at-startup
      }
      environment {
        DMS_RUN_GREETER "1"
      }
      gestures {
        hot-corners {
          off
        }
      }
      layout {
        background-color "#000000"
      }
      cursor {
        xcursor-theme "Simp1e-Adw-Dark"
        xcursor-size 16
      }
      output "DP-5" {
        mode "5120x1440@239.761"
        scale 1
      }
    '';
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
    kernelParams = ["nvidia.NVreg_EnableResizableBar=1" "systemd.machine_id=d5a63149336448f8be8455db3d62dd47"];
    initrd.kernelModules = ["nvidia" "nct6683"];
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
    mounts = [{
      what = "/dev/mapper/external";
      where = "/mnt/external";
      type = "btrfs";
      options = "subvolid=5,compress=zstd,noatime";
      wantedBy = ["dev-mapper-external.device"];
    }];
    services.btrbk-external-backup = {
      description = "btrbk backup to external disk";
      after = ["mnt-external.mount"];
      requires = ["mnt-external.mount"];
      wantedBy = ["mnt-external.mount"];
      path = ["/run/wrappers"];
      serviceConfig = {
        Type = "oneshot";
        User = "btrbk";
        Group = "btrbk";
        ExecStart = "${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/external.conf resume";
        ExecStartPost = [
          "+${pkgs.util-linux}/bin/umount /mnt/external"
          "+${pkgs.systemd}/bin/systemd-cryptsetup detach external"
        ];
      };
    };
  };

  services = {
    btrbk.instances.external = {
      onCalendar = null;
      settings = {
        snapshot_create = "no";
        target_preserve_min = "7d";
        target_preserve = "30d";
        snapshot_dir = "/.snapshots";
        subvolume."/home".target = "/mnt/external";
      };
    };
    xserver.videoDrivers = ["nvidia"];
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
