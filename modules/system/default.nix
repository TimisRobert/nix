{
  pkgs,
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
      dates = "00:00";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    configPackages = [pkgs.xdg-desktop-portal-wlr];
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

  systemd = {
    services.NetworkManager-wait-online.enable = false;
  };

  networking = {
    hostName = hostName;
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
      extraGroups = ["wheel" "video"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
      ];
      initialHashedPassword = "$6$j/pzPQRWiXIb13xT$KWBX22k/90J1RWpB8iUjeqTHpPO0Ip8eGE4K8UOfJYqLgbvzhK1reLBJfIUWAVc6rhRN1i7VeF4v8prrVOUzx/";
    };
  };

  environment = {
    systemPackages = [pkgs.vim];
    persistence = {
      "/nix/persist" = {
        directories = ["/var/log" "/etc/NetworkManager/system-connections"];
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

  # i18n.consoleUseXkbConfig = true;

  services = {
    # xserver.layout = "us,ua";
    # xserver.xkbVariant = "colemak";
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
    blueman.enable = true;
  };

  hardware.opengl.enable = true;
  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true;
  zramSwap.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = [(pkgs.nerdfonts.override {fonts = ["Mononoki"];})];
    fontconfig = {
      defaultFonts = {monospace = ["Mononoki Nerd Font Mono"];};
    };
  };

  system.stateVersion = "23.05";
}
