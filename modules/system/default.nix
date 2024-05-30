{
  pkgs,
  lib,
  inputs,
  config,
  hostName,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "12:00";
      options = "--delete-older-than 14d";
    };
    settings = {
      trusted-users = ["rob"];
    };
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["zfs"];
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r zpool/root@blank
    '';
  };

  powerManagement.cpuFreqGovernor = "performance";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };

  networking = {
    hostName = hostName;
    nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    networkmanager.enable = true;
    nftables.enable = true;
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    light.enable = true;
    fuse.userAllowOther = true;
    fish = {
      enable = true;
      vendor.config.enable = false;
    };
  };

  users = {
    mutableUsers = false;
    users.root = {
      initialHashedPassword = "$6$j/pzPQRWiXIb13xT$KWBX22k/90J1RWpB8iUjeqTHpPO0Ip8eGE4K8UOfJYqLgbvzhK1reLBJfIUWAVc6rhRN1i7VeF4v8prrVOUzx/";
    };
    users.rob = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = ["wheel" "podman"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
      ];
      initialHashedPassword = "$6$j/pzPQRWiXIb13xT$KWBX22k/90J1RWpB8iUjeqTHpPO0Ip8eGE4K8UOfJYqLgbvzhK1reLBJfIUWAVc6rhRN1i7VeF4v8prrVOUzx/";
    };
  };

  environment = {
    systemPackages = [pkgs.vim];
    persistence = {
      "/persist" = {
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/etc/NetworkManager"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      };
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services = {
    zrepl = {
      enable = true;
      settings = {
        jobs = [
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
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      dnsovertls = "true";
    };
    devmon.enable = true;
    udisks2.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    dbus.enable = true;
    blueman.enable = true;
  };

  hardware = {
    opengl.enable = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [(pkgs.nerdfonts.override {fonts = ["Mononoki"];})];
    fontconfig = {
      defaultFonts = {monospace = ["Mononoki Nerd Font Mono"];};
    };
  };

  system.stateVersion = "23.11";
}
