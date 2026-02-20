{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./pam_keyinit.nix
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms.nixosModules.greeter
  ];

  nix = {
    settings = {
      trusted-users = ["rob"];
      download-buffer-size = 500 * 1024 * 1024;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

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
    initrd = {
      verbose = false;
      systemd.enable = true;
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
      settings.keyfile.path = "/var/lib/NetworkManager/system-connections";
    };
    nftables.enable = true;
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["virbr0"];
    };
  };

  systemd.services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    containers = {
      enable = true;
      registries.insecure = ["localhost"];
    };
    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          features.cdi = true;
          dns = ["1.1.1.1" "8.8.8.8"];
        };
      };
    };
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    virt-manager.enable = true;
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
    niri = {
      enable = true;
    };
    dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/rob";
      };
    };
    dsearch = {
      enable = true;
      systemd.enable = true;
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
      extraGroups = ["networkmanager" "video" "wheel" "libvirtd"];
      hashedPassword = "$6$/Tnn1OsR9WY/nlF/$AO2RGm.2NYUeh9LIPH8Zl2IachZXSnG/iRM1y0R.TkD00BnwztAQrYOS/XcVQfSy7MYqRDK5mvhDGLQDzm2AU/";
    };
  };

  environment = {
    systemPackages = [pkgs.vim pkgs.dnsmasq pkgs.simp1e-cursors];
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
        login = {
          u2fAuth = true;
        };
        sudo.u2fAuth = true;
      };
    };
  };

  services = {
    btrbk.instances.local = {
      onCalendar = "*:0/10";
      settings = {
        snapshot_preserve_min = "2h";
        snapshot_preserve = "24h 30d";
        snapshot_dir = "/.snapshots";
        subvolume."/home" = {};
      };
    };
    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/nix"];
    };
    udev.packages = [pkgs.yubikey-personalization];
    pcscd.enable = true;
    tailscale.enable = true;
    fwupd.enable = true;
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSOverTLS = "opportunistic";
          # DNSSEC = "true";
        };
      };
    };
    devmon.enable = true;
    udisks2.enable = true;
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
          FastConnectable = true;
          Enable = "Source,Sink,Media,Socket";
          AutoEnable = true;
        };
      };
    };
    enableRedistributableFirmware = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [pkgs.mononoki pkgs.nerd-fonts.mononoki pkgs.inter];
    fontconfig.defaultFonts = {
      monospace = ["Mononoki Nerd Font Mono"];
      sansSerif = ["Inter"];
    };
  };

  system = {
    stateVersion = "25.05";
  };
}
