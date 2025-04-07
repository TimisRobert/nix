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
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
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

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "plymouth.use-simpledrm"
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
    nameservers = ["1.1.1.1" "2606:4700:4700::1111"];
    firewall.trustedInterfaces = ["vlan" "br0" "macvlan"];
  };

  virtualisation = {
    incus = {
      enable = true;
      ui.enable = true;
      package = pkgs.incus;
      preseed = {};
    };
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
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
      extraGroups = ["networkmanager" "video" "wheel" "incus-admin"];
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
          "/var/lib/nixos"
          "/var/lib/incus"
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

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
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
      domains = ["~."];
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
