{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./pam_keyinit.nix
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
      extraPackages = [pkgs.zfs];
      defaultNetwork.settings.dns_enabled = true;
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

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      sshKeyPaths = ["/persist/ssh/ssh_host_ed25519_key"];
    };
    secrets = {
      hashed_password = {
        neededForUsers = true;
      };
    };
  };

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "!";
    };
    users.rob = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = ["networkmanager" "video" "wheel"];
      hashedPasswordFile = config.sops.secrets.hashed_password.path;
    };
  };

  environment = {
    systemPackages = [pkgs.vim];
    etc = {
      machine-id.source = "/persist/etc/machine-id";
      "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam = {
      u2f = {
        enable = true;
        settings = {
          origin = "pam://yubi";
          authfile = pkgs.writeText "u2f-mappings" "rob:tYZ1q1LPiaIpSpc1XQLMowi0+fDIZ6vlYPuXUNfZjDrGYcJQww720iaCKkeOoILtDmMx2JtYrLSyEobF7549ZA==,aaliofoBZbTsvvCziNJzp8rjU60hKFBut9/PG4Fp5seOTNMBeyfBBSPqkHVa8tmEslsNGPJ2mMmGe409eTJ7ZA==,es256,+presence";
          cue = true;
        };
      };
      services = {
        hyprlock.enable = true;
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
    };
  };

  services = {
    spice-vdagentd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    pcscd.enable = true;
    tailscale.enable = true;
    fwupd.enable = true;
    zfs = {
      autoSnapshot = {
        enable = true;
      };
      autoScrub = {
        enable = true;
        interval = "14:00 Europe/Rome";
      };
      trim.enable = true;
    };
    resolved = {
      enable = true;
      # dnssec = "true";
      dnsovertls = "opportunistic";
      fallbackDns = ["1.1.1.1#one.one.one.one" "2606:4700:4700::1111#one.one.one.one"];
    };
    devmon.enable = true;
    udisks2.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "uwsm start ${config.programs.hyprland.package}/share/wayland-sessions/hyprland.desktop";
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
      wireplumber.extraConfig = {
        bluetoothEnhancements = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = false;
            "bluez5.enable-hw-volume" = true;
            "bluez5.auto-connect" = ["a2dp_sink"];
            "bluez5.roles" = ["a2dp_sink" "a2dp_source"];
          };
        };
        defaultMicrophone = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "media.class" = "equals:Audio/Source";
                  "node.name" = "matches:rnnoise_source";
                }
              ];
              actions = {
                update-props = {
                  "priority.session" = 2000;
                };
              };
            }
          ];
        };
      };
    };
    dbus.enable = true;
    blueman.enable = true;
  };

  hardware = {
    gpgSmartcards.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };
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
