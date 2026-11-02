{
  config,
  pkgs,
  ...
}: {
  services.displayManager.noctalia-greeter.settings.output = {
    name = "DP-4";
    width = 5120;
    height = 1440;
    scale = 1.0;
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
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
    extraModprobeConfig = ''
      options kvm_amd nested=1
    '';
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

  environment.etc.crypttab.text = ''
    external UUID=93d9a8a9-1a05-4a55-a669-0e2f1f71836d - fido2-device=auto,nofail
  '';

  networking = {
    hostName = "desktop";
  };

  systemd = {
    sleep.settings.Sleep.SuspendState = "mem";
    mounts = [
      {
        what = "/dev/mapper/external";
        where = "/mnt/external";
        type = "btrfs";
        options = "subvolid=5,compress=zstd,noatime";
        wantedBy = ["dev-mapper-external.device"];
      }
    ];
    services.btrbk-external.unitConfig.RequiresMountsFor = "/mnt/external";
  };

  services = {
    power-profiles-daemon.enable = false;
    btrbk.instances.external = {
      onCalendar = "hourly";
      settings = {
        snapshot_create = "no";
        target_preserve_min = "latest";
        target_preserve = "7d *m";
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
