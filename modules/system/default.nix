{
  pkgs,
  lib,
  ...
}: {
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

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];

  boot = {
    binfmt = {
      emulatedSystems = ["aarch64-linux"];
      preferStaticEmulators = true;
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        consoleMode = "max";
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs"];

    initrd = {
      verbose = false;
      systemd = {
        enable = true;
        services.rollback = {
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

    plymouth = {
      enable = true;
      theme = "hexagon_red";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {selected_themes = ["hexagon_red"];})
      ];
    };

    kernel.sysctl."vm.max_map_count" = 2147483642;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  zramSwap.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    nftables.enable = true;
    nameservers = ["1.1.1.1#one.one.one.one" "2606:4700:4700::1111#one.one.one.one"];
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [6443 10250];
      allowedUDPPorts = [8472 51820 51821];
    };
  };

  virtualisation = {
    containers = {
      enable = true;
    };
    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
      extraPackages = [pkgs.zfs];
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    appimage = {
      enable = true;
      binfmt = true;
    };
    nix-ld.enable = true;
    light.enable = true;
    fuse.userAllowOther = true;
    fish = {
      enable = true;
      vendor.config.enable = false;
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
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
      extraGroups = ["networkmanager" "video" "wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
      ];
      initialHashedPassword = "$6$j/pzPQRWiXIb13xT$KWBX22k/90J1RWpB8iUjeqTHpPO0Ip8eGE4K8UOfJYqLgbvzhK1reLBJfIUWAVc6rhRN1i7VeF4v8prrVOUzx/";
    };
  };

  environment = {
    systemPackages = [pkgs.vim];
    etc = {
      machine-id.source = "/persist/etc/machine-id";
      rancher.source = "/persist/etc/rancher/";
      "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    tailscale.enable = true;
    fwupd.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "14:00 Europe/Rome";
      };
      trim.enable = true;
    };
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      fallbackDns = ["1.1.1.1#one.one.one.one" "2606:4700:4700::1111#one.one.one.one"];
    };
    dnsmasq = {
      enable = true;
      settings = {
        port = 5454;
        no-resolv = true;
        listen-address = ["127.0.0.1"];
        address = ["/cluster.internal/127.0.0.1"];
      };
    };
    devmon.enable = true;
    udisks2.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "rob";
        };
        default_session = initial_session;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = ["aac" "sbc_xq" "sbc"];
        };
      };
    };
    dbus.enable = true;
    blueman.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [pkgs.mononoki pkgs.nerd-fonts.mononoki];
    fontconfig.defaultFonts = {monospace = ["Mononoki Nerd Font Mono"];};
  };

  system = {
    stateVersion = "25.05";
  };
}
