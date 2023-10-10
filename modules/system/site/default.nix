{ pkgs, config, inputs, modulesPath, lib, hostName, ... }: {
  imports = [
    "${modulesPath}/profiles/hardened.nix"
    inputs.agenix.nixosModules.default
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
  security.lockKernelModules = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams =
    lib.mkForce [ "page_alloc.shuffle=1" "init_on_alloc=1" "init_on_free=1" ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = { dns_enabled = true; };
    };
    oci-containers = {
      backend = "podman";
      containers = {
        personal_site = {
          login = {
            username = "RobertTimis";
            passwordFile = config.age.secrets.forgejo.path;
          };
          autoStart = true;
          image = "git.roberttimis.com/roberttimis/personal_site:main";
          extraOptions = [
            "--network=slirp4netns:allow_host_loopback=true"
            "--pull=newer"
          ];
          ports = [ "4000:4000" ];
          environmentFiles = [ config.age.secrets.personal_site.path ];
        };
      };
    };
  };

  environment = {
    systemPackages = [ pkgs.neovim ];
    persistence = {
      "/nix/persist" = {
        directories = [ "/var/log" "/var/lib/acme" ];
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

  age = {
    identityPaths = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      hetznerDns = {
        file = ../../../secrets/hetznerDns.age;
        owner = "acme";
        group = "acme";
      };
      forgejo = { file = ../../../secrets/forgejo.age; };
      personal_site = { file = ../../../secrets/personal_site.age; };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = { email = "roberttimis@gmail.com"; };
    certs = {
      "roberttimis.com" = {
        domain = "roberttimis.com";
        dnsProvider = "hetzner";
        credentialsFile = config.age.secrets.hetznerDns.path;
      };
    };
  };

  programs.zsh.enable = true;

  services = {
    resolved.enable = true;
    postgresql = {
      enable = true;
      ensureUsers = [{ name = "personal_site"; }];
      ensureDatabases = [ "personal_site" ];
      authentication = ''
        local all postgres peer map=root
      '';
      identMap = ''
        root root postgres
        root postgres postgres
      '';
    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts = {
        "roberttimis.com" = {
          forceSSL = true;
          useACMEHost = "roberttimis.com";
          locations."/".proxyPass = "http://localhost:4000";
        };
      };
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = { Address = [ "2a01:4f8:c012:7eef::/64" ]; };
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
        DHCP = "ipv4";
      };
    };
  };

  networking = {
    inherit hostName;
    useDHCP = false;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  zramSwap.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      nginx = { extraGroups = [ "acme" ]; };
      root = {
        initialHashedPassword =
          "$6$8vuSs91NJ39SZy.b$b2ujBj2.iq9pPpZD0XL4yS7oJ0ODG2eGfGf7YVLt5OLkthe1tgKyEYPzRDTNO9J0Om1mVPIdpCWE7MIwKspDa/";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/Uq1z6b6ITxQv6YhjTV6kNoOiQWAqDiJivnPPByM4q root@nixos"
        ];
      };
    };
  };

  system.stateVersion = "23.05";
}
