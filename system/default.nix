{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  nix = {
    settings = {
      trusted-users = ["rob"];
      download-buffer-size = 500 * 1024 * 1024;
      substituters = [
        "https://cache.nixos-cuda.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        niri = prev.niri.override {
          libdisplay-info = prev.libdisplay-info.overrideAttrs (_: rec {
            version = "0.3.0";
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "emersion";
              repo = "libdisplay-info";
              rev = version;
              hash = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
            };
          });
        };
      })
    ];
  };

  stylix = {
    enable = true;
    targets.kmscon.enable = false;
    targets.plymouth.enable = false;
    base16Scheme = {
      scheme = "Kanagawa";
      author = "rebelot (https://github.com/rebelot)";
      base00 = "1F1F28";
      base01 = "2A2A37";
      base02 = "363646";
      base03 = "54546D";
      base04 = "C8C093";
      base05 = "DCD7BA";
      base06 = "938AA9";
      base07 = "363646";
      base08 = "C34043";
      base09 = "FFA066";
      base0A = "DCA561";
      base0B = "98BB6C";
      base0C = "7FB4CA";
      base0D = "7E9CD8";
      base0E = "957FB8";
      base0F = "D27E99";
    };
    cursor = {
      name = "Simp1e-Adw-Dark";
      package = pkgs.simp1e-cursors;
      size = 16;
    };
    fonts = {
      monospace = {
        name = "Mononoki Nerd Font Mono";
        package = pkgs.nerd-fonts.mononoki;
      };
      sansSerif = {
        name = "Inter";
        package = pkgs.inter;
      };
      sizes = {
        terminal = 12;
        desktop = 12;
        popups = 10;
        applications = 11;
      };
    };
    opacity.terminal = 0.95;
    polarity = "dark";
  };

  fonts.packages = [
    pkgs.noto-fonts-cjk-sans
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
    initrd = {
      verbose = false;
      systemd.enable = true;
    };

    plymouth.enable = true;

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
      trustedInterfaces = ["virbr*"];
    };
  };

  systemd.services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";

  virtualisation = {
    containers = {
      enable = true;
      registries.settings.registry = [
        {location = "docker.io";}
        {location = "quay.io";}
        {
          location = "localhost";
          insecure = true;
        }
      ];
    };
    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          features = {
            "cdi" = true;
            "containerd-snapshotter" = true;
          };
          dns = ["1.1.1.1" "8.8.8.8"];
        };
      };
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
    fuse.userAllowOther = true;
    fish = {
      enable = true;
      vendor.config.enable = false;
    };
    niri = {
      enable = true;
    };
    noctalia-greeter = {
      enable = true;
      greeter-args = "--session niri";
      settings = {
        auth.allow_empty_password = true;
        appearance.scheme = "Synced";
        cursor = {
          theme = "Simp1e-Adw-Dark";
          size = 16;
          package = pkgs.simp1e-cursors;
        };
        idle.timeout = 300;
        keyboard.numlock = true;
      };
    };
  };

  users = {
    mutableUsers = true;
    users.root = {
      hashedPassword = "!";
    };
    users.rob = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = ["networkmanager" "video" "wheel"];
    };
  };

  environment = {
    systemPackages = [pkgs.vim pkgs.simp1e-cursors];
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
        login.u2fAuth = true;
        sudo.u2fAuth = true;
        greetd = {
          u2fAuth = true;
          fprintAuth = true;
          enableGnomeKeyring = false;
        };
      };
    };
  };

  services = {
    accounts-daemon.enable = true;
    power-profiles-daemon.enable = lib.mkDefault true;
    upower.enable = true;
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
          FallbackDNS = ["1.1.1.1"];
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
      extraLadspaPackages = [pkgs.rnnoise-plugin.ladspa];
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
    ksm.enable = true;
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

  system = {
    stateVersion = "25.05";
  };
}
